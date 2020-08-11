//
//  GXRefreshBaseHeaderView.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/10.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshBaseHeader: GXRefreshComponent {
    private var isPlayingImpact: Bool = false
}

extension GXRefreshBaseHeader {
    override func prepare() {
        super.prepare()
        self.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin]
        self.gx_height = GXRefreshConfiguration.shared.headerHeight
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
            guard offset.y < justOffsetY else { return }
            // did/end状态的情况
            guard self.state != .did && self.state != .end else { return }
            // 需要拉到刷新的offsetY
            let pullingOffsetY = justOffsetY - self.gx_height
            // 刷新头部视图透明百分比进度
            let pullingProgress: CGFloat = (justOffsetY - offset.y) / self.gx_height
            
            // 判断是否正在拖拽
            if self.scrollView!.isDragging {
                self.pullingProgress = pullingProgress
                if ((self.state == .idle || self.state == .will) && offset.y > pullingOffsetY) {
                    self.state = .pulling
                }
                else if (self.state == .pulling && offset.y <= pullingOffsetY) {
                    self.state = .will
                    if !self.isPlayingImpact {
                        self.isPlayingImpact = true
                        GXRefreshConfiguration.shared.playImpact()
                    }
                }
                else if (self.state == .pulling && offset.y > pullingOffsetY + self.gx_height/3) {
                    // 设置回到1/3处为二次震动重置点
                    self.isPlayingImpact = false
                }
            }
            else {
                if self.state == .will {
                    self.state = .did
                }
                else {
                    self.state = .idle
                    self.pullingProgress = pullingProgress
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
            DispatchQueue.main.asyncAfter(deadline: .now() + GXRefreshConfiguration.shared.enRefreshDelay) {
                self.endStateRefreshing()
            }
        }
    }
}

fileprivate extension GXRefreshBaseHeader {
    func didStateRefreshing() {
        var contentOffset = self.contentOffset
        var contentInset = self.contentInset
        contentInset.top = self.scrollViewOriginalInset.top + self.gx_height
        if self.oldState == .idle {
            contentOffset.y -= self.gx_height
            UIView.animate(withDuration: GXRefreshConfiguration.shared.animationDuration, animations: {
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
        UIView.animate(withDuration: GXRefreshConfiguration.shared.animationDuration, animations: {
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
    
    func endRefreshing() {
        self.state = .end
    }
}
