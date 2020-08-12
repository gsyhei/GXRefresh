//
//  GXRefreshBaseFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/11.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshBaseFooter: GXRefreshComponent {
    open var automaticallyRefresh: Bool = false
    open var automaticallyRefreshPercent: CGFloat = 1.0
    open var footerHeight: CGFloat = 44.0 {
        didSet {
            self.gx_height = self.footerHeight
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard !self.isHidden && self.scrollView != nil else { return }
        
        var contentInset = self.contentInset
        contentInset.bottom = self.scrollViewOriginalInset.bottom + self.gx_height
        self.scrollView?.contentInset = contentInset
    }
}

extension GXRefreshBaseFooter {
    override func prepare() {
        super.prepare()
        self.gx_height = self.footerHeight
        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = self.contentSize.height + self.scrollViewOriginalInset.bottom
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 需要内容超过屏幕
            let contentH = self.contentSize.height + self.adjustedInset.top + self.adjustedInset.bottom
            guard contentH > self.scrollView!.gx_height else { return }
            // 判断header是否出现
            var justOffsetY = self.contentSize.height + self.adjustedInset.bottom
            justOffsetY -= (self.scrollView!.gx_height + self.gx_height)
            guard offset.y >= justOffsetY else { return }
            // did/end状态的情况
            guard self.state != .did && self.state != .end else { return }
            // 需要拉到刷新的offsetY
            let footerHeight = self.gx_height * self.automaticallyRefreshPercent
            let pullingOffsetY = justOffsetY + footerHeight
            // 刷新头部视图透明百分比进度
            let pullingProgress: CGFloat = (offset.y - justOffsetY) / footerHeight
            self.pullingProgress = pullingProgress
            // 自动刷新是否开启
            if self.automaticallyRefresh {
                if self.state == .idle && offset.y >= pullingOffsetY {
                    self.state = .did
                }
            }
            else {
                // 判断是否正在拖拽
                if self.scrollView!.isDragging && self.scrollView!.isTracking {
                    if ((self.state == .idle || self.state == .will) && offset.y < pullingOffsetY) {
                        self.state = .pulling
                    }
                    else if (self.state == .idle || self.state == .pulling && offset.y >= pullingOffsetY) {
                        self.state = .will
                    }
                    else if (self.state == .will && offset.y >= pullingOffsetY) {
                        self.state = .did
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
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
        self.gx_top = self.contentSize.height + self.scrollViewOriginalInset.bottom
        
        if (!isChageAlpha()) {
            self.alpha = 1.0
        }
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
        guard self.state == .idle else { return }
        
        if let panState = change?[NSKeyValueChangeKey.newKey] as? Int {
            // state == .ended
            guard (panState == UIGestureRecognizer.State.ended.rawValue) else { return }
            // 需要内容小于屏幕
            let contentH = self.contentSize.height + self.adjustedInset.top + self.adjustedInset.bottom
            guard (contentH < self.scrollView!.gx_height) else { return }
     
            if (self.contentOffset.y > -self.adjustedInset.top) {
                self.state = .did
            }
        }
    }
    
    override func setState(_ state: State) {
        super.setState(state)
        if state == .did {
            self.didStateRefreshing()
        }
        else if state == .end {
            self.endStateRefreshing()
        }
        else if state == .noMore {
            self.endStateRefreshing(isNoMore: true)
        }
    }
}

fileprivate extension GXRefreshBaseFooter {
    func isChageAlpha() -> Bool {
        let contentH = self.contentSize.height + self.adjustedInset.top + self.adjustedInset.bottom
        return (contentH >= self.scrollView!.gx_height)
    }
    func didStateRefreshing() {
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
    func endStateRefreshing(isNoMore: Bool = false) {
        if !isNoMore {
            self.state = .idle
        }
        if self.automaticallyChangeAlpha && isChageAlpha() {
            self.alpha = 0.0
        }
        if self.endRefreshingCompletionAction != nil {
            self.endRefreshingCompletionAction!()
        }
    }
}

extension GXRefreshBaseFooter {
    func beginRefreshing() {
        self.state = .did
    }
    func endRefreshing(isNoMore: Bool = false) {
        self.state = isNoMore ? .noMore : .end
    }
}
