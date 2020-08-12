//
//  GXRefreshNormalFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/12.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshNormalFooter: GXRefreshBaseFooter {
    private lazy var footerText: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "点击或上拉加载更多",
                .pulling: "上拉加载更多",
                .will: "放开立即加载更多",
                .did: "正在加载更多数据...",
                .noMore: "已加载全部数据"]
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

fileprivate extension GXRefreshNormalFooter {
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
    @objc func contentClicked(_ sender: UIControl) {
        self.beginRefreshing()
    }
}

extension GXRefreshNormalFooter {
    override func prepare() {
        super.prepare()
        self.textLabel.text = self.footerText[.idle]
        self.updateTextLabel()
        self.contentView.addTarget(self, action: #selector(self.contentClicked(_:)), for: .touchUpInside)
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.updateTextLabel()
    }
    override func setState(_ state: State) {
        super.setState(state)
        
        if let text = self.footerText[state] {
            self.textLabel.text = text
            self.updateTextLabel()
        }
        if state == .did {
            self.indicator.startAnimating()
        }
        else if state == .end || state == .noMore {
            self.indicator.stopAnimating()
        }
    }
}

extension GXRefreshNormalFooter {
    func setFooterText(_ text: String, for state: GXRefreshComponent.State) {
        self.footerText.updateValue(text, forKey: state)
        if self.state == state {
            self.textLabel.text = text
        }
    }
}
