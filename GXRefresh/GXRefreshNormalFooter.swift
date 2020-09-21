//
//  GXRefreshNormalFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/12.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshNormalFooter: GXRefreshBaseFooter {
    private(set) lazy var indicator: UIActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        let aiView = UIActivityIndicatorView(frame: frame)
        if #available(iOS 13.0, *) {
            aiView.style = .medium
        } else {
            aiView.style = .gray
        }
        return aiView
    }()
    public override var customIndicator: UIView {
        return self.indicator
    }
}

public extension GXRefreshNormalFooter {
    override func setState(_ state: State) {
        super.setState(state)
        
        if state == .did {
            self.indicator.startAnimating()
        }
        else if state == .end || state == .noMore {
            self.indicator.stopAnimating()
        }
    }
}
