//
//  GXRefreshNormalHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/12.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshNormalHeader: GXRefreshBaseHeader {
    
    open lazy var indicator: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            aiView.style = .medium
        } else {
            aiView.style = .gray
        }
        self.contentView.addSubview(aiView)
        return aiView
    }()
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(label)
        return label
    }()
}

fileprivate extension GXRefreshNormalHeader {
    func updateTextLabel() {
        let nsText: NSString = (self.textLabel.text ?? "") as NSString
        let maxSize = self.bounds.size
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let attributes: [NSAttributedString.Key : Any] = [.font : self.textLabel.font!]
        let rect = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        self.textLabel.frame = rect
        self.textLabel.center = self.contentView.center
        self.indicator.center.y = self.contentView.center.y
        self.indicator.gx_right = self.textLabel.gx_left - 20.0
    }
}

extension GXRefreshNormalHeader {
    override func prepare() {
        super.prepare()
        self.textLabel.text = GXRefreshConfiguration.shared.headerTextDict[.idle]
        self.updateTextLabel()
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.updateTextLabel()
    }
    override func setState(_ state: State) {
        super.setState(state)
        
        if let text = GXRefreshConfiguration.shared.headerTextDict[state] {
            self.textLabel.text = text
            self.updateTextLabel()
        }
        if state == .did {
            self.indicator.startAnimating()
        }
        else if state == .end {
            self.indicator.stopAnimating()
        }
    }
}
