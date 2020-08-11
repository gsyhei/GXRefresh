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
        self.gx_height = GXRefreshConfiguration.shared.footerHeight
        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = self.contentSize.height + self.scrollViewOriginalInset.bottom
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 需要内容操作屏幕
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
            
            if self.automaticallyRefresh {
                if self.state == .idle && offset.y >= pullingOffsetY {
                    self.state = .did
                }
            }
            else {
                // 判断是否正在拖拽
                if self.scrollView!.isDragging {
                    if ((self.state == .idle || self.state == .will) && offset.y < pullingOffsetY) {
                        self.state = .pulling
                    }
                    else if (self.state == .pulling && offset.y >= pullingOffsetY) {
                        self.state = .will
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
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
        guard self.state == .idle else { return }
        
        if let panState = change?[NSKeyValueChangeKey.newKey] as? UIGestureRecognizer.State {
            // 需要内容小于屏幕 & state == .ended
            let contentH = self.contentSize.height + self.adjustedInset.top + self.adjustedInset.bottom
            guard (contentH < self.scrollView!.gx_height && panState == .ended) else { return }
     
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
    }
}

fileprivate extension GXRefreshBaseFooter {
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
    func endStateRefreshing() {
        self.state = .idle
        if self.automaticallyChangeAlpha {
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
    
    func endRefreshing() {
        self.state = .end
    }
}
