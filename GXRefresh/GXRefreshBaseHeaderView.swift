//
//  GXRefreshBaseHeaderView.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/10.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshBaseHeader: GXRefreshBaseView {
    
}

extension GXRefreshBaseHeader {
    override func prepare() {
        super.prepare()
        self.gx_top = -(self.gx_height + self.contentInset.top)
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_height = GXRefreshConfiguration.shared.headerHeight
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
    }
    
    override func setState(_ state: GXRefreshState) {
        super.setState(state)
        
    }
}
