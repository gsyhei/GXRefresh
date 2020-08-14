//
//  GXRefreshNormalFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/12.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshNormalFooter: GXRefreshBaseFooter {
    private lazy var footerTexts: Dictionary<GXRefreshComponent.State, String> = {
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
    @objc func contentClicked(_ sender: UIControl) {
        guard self.state == .idle else { return }
        self.beginRefreshing()
    }
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
        if let text = self.footerTexts[state] {
            self.textLabel.text = text
            self.updateContentViewLayout()
        }
    }
}

extension GXRefreshNormalFooter {
    override func prepare() {
        super.prepare()
        self.contentView.addTarget(self, action: #selector(self.contentClicked(_:)), for: .touchUpInside)
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
        else if state == .end || state == .noMore {
            self.indicator.stopAnimating()
        }
    }
}

extension GXRefreshNormalFooter {
    func setFooterText(_ text: String, for state: GXRefreshComponent.State) {
        self.footerTexts.updateValue(text, forKey: state)
        if self.state == state {
            self.textLabel.text = text
        }
    }
}
