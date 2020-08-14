//
//  GXRefreshCustomHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/14.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshCustomHeader: GXRefreshBaseHeader {
    open var stateCallBack: ((_ state: State) -> Void)? = nil
    open var progressCallBack: ((_ view: GXRefreshCustomHeader) -> Void)? = nil
    
    private lazy var customView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    }()
    override var customIndicator: UIView {
        return self.customView
    }
    override var pullingProgress: CGFloat {
        didSet {
            guard !self.isRefreshing else { return }
            if (self.progressCallBack != nil) {
                self.progressCallBack!(self)
            }
        }
    }
    override func setState(_ state: State) {
        super.setState(state)
        if (self.stateCallBack != nil) {
            self.stateCallBack!(state)
        }
    }
}

extension GXRefreshCustomHeader {
    open func updateCustomIndicator(view: UIView) {
        self.customIndicator.frame.size = view.frame.size
        self.customIndicator.addSubview(view)
        self.updateContentViewLayout()
    }
}
