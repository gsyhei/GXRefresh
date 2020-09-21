//
//  GXRefreshCustomFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/14.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshCustomFooter: GXRefreshBaseFooter {
    open var stateCallBack: ((_ state: State) -> Void)? = nil
    open var progressCallBack: ((_ view: GXRefreshCustomFooter) -> Void)? = nil

    private lazy var customView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    }()
    public override var customIndicator: UIView {
        return self.customView
    }
    public override var pullingProgress: CGFloat {
        didSet {
            guard !self.isRefreshing && !self.automaticallyRefresh else { return }
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

public extension GXRefreshCustomFooter {
    func updateCustomIndicator(view: UIView) {
        self.customIndicator.frame.size = view.frame.size
        self.customIndicator.addSubview(view)
        if (view.frame.size.height > self.gx_height) {
            self.gx_height = view.frame.size.height
        }
        self.updateContentViewLayout()
    }
}
