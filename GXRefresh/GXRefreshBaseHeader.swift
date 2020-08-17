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
    open var dataSource: ((_ state: State) -> Void)? = nil
    open var isTextHidden: Bool = false
    open var isPlayImpact: Bool = true
    open var isShowEndRefresh: Bool = true
    open var animationDuration: TimeInterval = 0.25
    open var endRefreshDelay: TimeInterval = 0.7
    open var automaticallyRefreshPercent: CGFloat = 1.0
    open var headerHeight: CGFloat = 54.0 {
        didSet {
            self.gx_height = self.headerHeight
        }
    }
    open var textToIndicatorSpacing: CGFloat = 10.0 {
        didSet {
            self.updateContentViewLayout()
        }
    }
    private(set) lazy var refreshTitles: Dictionary<State, String> = {
        return [.idle: "下拉刷新",
                .pulling: "下拉可以刷新",
                .will: "放开立即刷新",
                .did: "正在刷新...",
                .end: "刷新完成"]
    }()
    
    open var customIndicator: UIView {
        return UIView()
    }
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
        
    private var isPlayingImpact: Bool = false
    @available(iOS 10.0, *)
    private lazy var generator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .light)
    }()
}

extension GXRefreshBaseHeader {
    override func prepare() {
        super.prepare()
        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
        self.gx_height = self.headerHeight
        self.contentView.addSubview(self.customIndicator)
        self.contentView.addSubview(self.textLabel)
        self.updateContentView(state: .idle)
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = -(self.gx_height + self.svContentInset.top)
        self.updateContentViewLayout()
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 判断header是否出现
            let justOffsetY = -self.svAdjustedInset.top
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
            let headerHeight = self.gx_height * self.automaticallyRefreshPercent
            let pullingOffsetY = justOffsetY - headerHeight
            // 刷新头部视图透明百分比进度
            let pullingProgress: CGFloat = (justOffsetY - offset.y) / headerHeight
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
                else if (offset.y <= pullingOffsetY) {
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
        self.updateContentView(state: state)
        if state == .did {
            self.didStateRefreshing()
        }
        else if state == .end {
            if self.isShowEndRefresh {
                GXRefreshIndicatorView.show(to: self.contentView,
                                            strokeColor: self.textLabel.textColor,
                                            animationDuration: self.endRefreshDelay,
                                            center: self.customIndicator.center)
                {
                    self.endStateRefreshing()
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                    self.endStateRefreshing()
                }
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
        var contentOffset = self.svContentOffset
        var contentInset = self.svContentInset
        let headerHeight = self.gx_height * self.automaticallyRefreshPercent
        contentInset.top = self.scrollViewOriginalInset.top + headerHeight
        if self.oldState == .idle {
            contentOffset.y -= headerHeight
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
                if self.beginRefreshingAction != nil {
                    self.beginRefreshingAction!()
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
            if self.beginRefreshingAction != nil {
                self.beginRefreshingAction!()
            }
        }
    }
    func endStateRefreshing() {
        var contentInset = self.svContentInset
        contentInset.top = self.scrollViewOriginalInset.top
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.scrollView?.contentInset = contentInset
            if self.automaticallyChangeAlpha {
                self.alpha = 0.0
            }
        }) { (finished) in
            self.state = .idle
            self.isPlayingImpact = false
            if self.isShowEndRefresh {
                GXRefreshIndicatorView.hide(to: self.contentView)
            }
            if self.endRefreshingAction != nil {
                self.endRefreshingAction!()
            }
        }
    }
}

extension GXRefreshBaseHeader {
    open func beginRefreshing() {
        self.state = .did
    }
    open func endRefreshing(isNoMore: Bool = false) {
        self.state = .end
        self.scrollView?.gx_footer?.endRefreshing(isNoMore: isNoMore)
    }
    open func updateContentViewLayout() {
        self.textLabel.isHidden =  self.isTextHidden
        if self.isTextHidden {
            self.customIndicator.center = self.contentView.center
        }
        else {
            let nsText: NSString = (self.textLabel.text ?? "") as NSString
            let maxSize = self.contentView.bounds.size
            let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let attributes: [NSAttributedString.Key : Any] = [.font : self.textLabel.font!]
            let rect = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
            self.textLabel.frame = rect
            self.textLabel.center = CGPoint(x: self.contentView.gx_width/2, y: self.contentView.gx_height/2)
            self.customIndicator.center.y = self.textLabel.center.y
            self.customIndicator.gx_right = self.textLabel.gx_left - self.textToIndicatorSpacing
        }
    }
    open func updateContentView(state: State) {
        if let text = self.refreshTitles[state] {
            self.textLabel.text = text
        }
        if self.dataSource != nil {
            self.dataSource!(state)
        }
        self.updateContentViewLayout()
    }
    open func setRefreshTitles(_ text: String, for state: State) {
        self.refreshTitles.updateValue(text, forKey: state)
        if self.state == state {
            self.textLabel.text = text
        }
    }
}
