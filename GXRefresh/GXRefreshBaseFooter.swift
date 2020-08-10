//
//  GXRefreshBaseFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/11.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshBaseFooter: GXRefreshComponent {
    open var automaticallyRefresh: Bool = true
    open var automaticallyRefreshPercent: CGFloat = 1.0
}

extension GXRefreshBaseFooter {
    override func prepare() {
        super.prepare()
        self.gx_height = GXRefreshConfiguration.shared.footerHeight
        //        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = self.contentSize.height
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        
        
        
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 需要内容操作屏幕
            var contentW = self.contentSize.height + self.adjustedInset.bottom
            guard contentW > self.scrollView!.gx_height else { return }
            
            // 判断header是否出现
            let justOffsetY = -self.adjustedInset.top
            guard offset.y < justOffsetY else { return }
            
//            
//            // did/end状态的情况
//            guard self.state != .did && self.state != .end else { return }
//            // 需要拉到刷新的offsetY
//            let pullingOffsetY = justOffsetY - self.gx_height;
//            // 刷新头部视图透明百分比进度
//            let pullingProgress: CGFloat = (justOffsetY - offset.y) / self.gx_height
//            
//            // 判断是否正在拖拽
//            if self.scrollView!.isDragging {
//                self.pullingProgress = pullingProgress
//                if ((self.state == .idle || self.state == .will) && offset.y > pullingOffsetY) {
//                    self.state = .pulling
//                }
//                else if (self.state == .pulling && offset.y <= pullingOffsetY) {
//                    self.state = .will
//                }
//            }
//            else {
//                if self.state == .will {
//                    self.state = .did
//                }
//                else {
//                    self.state = .idle
//                    self.pullingProgress = pullingProgress
//                }
//            }
        }
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
        self.gx_top = self.contentSize.height
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
    }
    
    override func setState(_ state: State) {
        super.setState(state)
        
    }
}
