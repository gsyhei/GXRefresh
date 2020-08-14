//
//  GXRefreshBaseHeaderView.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/10.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit
import AudioToolbox

class GXRefreshBaseHeader: GXRefreshComponent {
    open var isPlayImpact: Bool = true
    open var animationDuration: TimeInterval = 0.25
    open var enRefreshDelay: TimeInterval = 0.5
    open var headerHeight: CGFloat = 54.0 {
        didSet {
            self.gx_height = self.headerHeight
        }
    }
    private var isPlayingImpact: Bool = false
    @available(iOS 10.0, *)
    private lazy var generator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .light)
    }()
}

extension GXRefreshBaseHeader {
    override func prepare() {
        super.prepare()
        self.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin]
        self.gx_height = self.headerHeight
        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = -(self.gx_height + self.contentInset.top)
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 判断header是否出现
            let justOffsetY = -self.adjustedInset.top
            guard offset.y < justOffsetY else {
                if (self.state == .pulling) {
                    // 设置回到看不见就重置震动播放
                    self.isPlayingImpact = false
                }
                return
            }
            // did/end状态的情况
            guard self.state != .did && self.state != .end else { return }
            // 需要拉到刷新的offsetY
            let pullingOffsetY = justOffsetY - self.gx_height
            // 刷新头部视图透明百分比进度
            let pullingProgress: CGFloat = (justOffsetY - offset.y) / self.gx_height
            self.pullingProgress = pullingProgress
            // 判断是否正在拖拽
            if self.scrollView!.isDragging && self.scrollView!.isTracking {
                if ((self.state == .idle || self.state == .will) && offset.y > pullingOffsetY) {
                    self.state = .pulling
                }
                else if (self.state == .pulling && offset.y <= pullingOffsetY) {
                    self.state = .will
                    if !self.isPlayingImpact {
                        self.isPlayingImpact = true
                        self.playImpact()
                    }
                }
            }
            else {
                if self.state == .will {
                    self.state = .did
                }
                else {
                    self.state = .idle
                }
            }
        }
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
    }
    
    override func setState(_ state: State) {
        super.setState(state)
        if state == .did {
            self.didStateRefreshing()
        }
        else if state == .end {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.enRefreshDelay) {
                self.endStateRefreshing()
            }
        }
    }
}

fileprivate extension GXRefreshBaseHeader {
    func playImpact() {
        guard self.isPlayImpact else { return }
        if #available(iOS 10.0, *) {
            self.generator.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1519)
        }
    }
    func didStateRefreshing() {
        var contentOffset = self.contentOffset
        var contentInset = self.contentInset
        contentInset.top = self.scrollViewOriginalInset.top + self.gx_height
        if self.oldState == .idle {
            contentOffset.y -= self.gx_height
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.scrollView?.contentInset = contentInset
                self.scrollView?.contentOffset = contentOffset
                if self.automaticallyChangeAlpha {
                    self.alpha = 1.0
                }
            }) { (finish) in
                if self.refreshingAction != nil {
                    self.refreshingAction!()
                }
                if self.beginRefreshingCompletionAction != nil {
                    self.beginRefreshingCompletionAction!()
                }
            }
        }
        else {
            self.scrollView?.contentInset = contentInset
            self.scrollView?.contentOffset = contentOffset
            if self.automaticallyChangeAlpha {
                self.alpha = 1.0
            }
            if self.refreshingAction != nil {
                self.refreshingAction!()
            }
            if self.beginRefreshingCompletionAction != nil {
                self.beginRefreshingCompletionAction!()
            }
        }
    }
    func endStateRefreshing() {
        var contentInset = self.contentInset
        contentInset.top = self.scrollViewOriginalInset.top
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.scrollView?.contentInset = contentInset
            if self.automaticallyChangeAlpha {
                self.alpha = 0.0
            }
        }) { (finished) in
            self.state = .idle
            self.isPlayingImpact = false
            if self.endRefreshingCompletionAction != nil {
                self.endRefreshingCompletionAction!()
            }
        }
    }
}

extension GXRefreshBaseHeader {
    func beginRefreshing() {
        self.state = .did
    }
    func endRefreshing(isNoMore: Bool = false) {
        self.state = .end
        self.scrollView?.gx_footer?.endRefreshing(isNoMore: isNoMore)
    }
}
