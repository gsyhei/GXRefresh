//
//  GXRefreshCustomHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/14.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshCustomHeader: GXRefreshBaseHeader {
    open var stateCallBack: ((_ state: State) -> Void)? = nil
    open var progressCallBack: ((_ view: GXRefreshCustomHeader) -> Void)? = nil
    
    private lazy var customView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    }()
    public override var customIndicator: UIView {
        return self.customView
    }
    public override var pullingProgress: CGFloat {
        didSet {
            guard !self.isRefreshing else { return }
            if (self.progressCallBack != nil) {
                self.progressCallBack!(self)
            }
        }
    }
    public override func setState(_ state: State) {
        super.setState(state)
        if (self.stateCallBack != nil) {
            self.stateCallBack!(state)
        }
    }
}

public extension GXRefreshCustomHeader {
    func updateCustomIndicator(view: UIView) {
        self.customIndicator.frame.size = view.frame.size
        self.customIndicator.addSubview(view)
        self.updateContentViewLayout()
    }
}
