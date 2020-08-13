//
//  GXRefreshNormalHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/12.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshNormalHeader: GXRefreshBaseHeader {
    private lazy var headerTexts: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "下拉刷新",
                .pulling: "下拉可以刷新",
                .will: "放开立即刷新",
                .did: "正在刷新...",
                .end: "刷新完成"]
    }()
    
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
    func updateContentViewLayout() {
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
    func updateContentView(state: State) {
        if let text = self.headerTexts[state] {
            self.textLabel.text = text
            self.updateContentViewLayout()
        }
    }
}

extension GXRefreshNormalHeader {
    override func prepare() {
        super.prepare()
        self.updateContentView(state: .idle)
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.updateContentViewLayout()
    }
    override func setState(_ state: State) {
        super.setState(state)
        
        self.updateContentView(state: state)
        if state == .did {
            self.indicator.startAnimating()
        }
        else if state == .end {
            self.indicator.stopAnimating()
        }
    }
}

extension GXRefreshNormalHeader {
    func setHeaderText(_ text: String, for state: GXRefreshComponent.State) {
        self.headerTexts.updateValue(text, forKey: state)
        if self.state == state {
            self.textLabel.text = text
        }
    }
}
