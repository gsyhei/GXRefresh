//
//  GXRefreshCustomFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/14.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshCustomFooter: GXRefreshBaseFooter {
    open var dataSource: GXRefreshDataSource? = nil
    
    private lazy var footerTexts: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "点击或上拉加载更多",
                .pulling: "上拉加载更多",
                .will: "放开立即加载更多",
                .did: "正在加载更多数据...",
                .noMore: "已加载全部数据"]
    }()
    
    open lazy var customIndicator: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        return view
    }()
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(label)
        return label
    }()
}

fileprivate extension GXRefreshCustomFooter {
    @objc func contentClicked(_ sender: UIControl) {
        guard self.state == .idle else { return }
        self.beginRefreshing()
    }
    func updateContentViewLayout() {
        if self.isHiddenText {
            self.customIndicator.center = self.contentView.center
        }
        else {
            let nsText: NSString = (self.textLabel.text ?? "") as NSString
            let maxSize = self.bounds.size
            let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let attributes: [NSAttributedString.Key : Any] = [.font : self.textLabel.font!]
            let rect = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
            self.textLabel.frame = rect
            self.textLabel.center = self.contentView.center
            self.customIndicator.center.y = self.contentView.center.y
            self.customIndicator.gx_right = self.textLabel.gx_left - 20.0
        }
    }
    func updateContentView(state: State) {
        if let text = self.footerTexts[state] {
            self.textLabel.text = text
            self.updateContentViewLayout()
        }
    }
}

extension GXRefreshCustomFooter {
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
        
        if self.dataSource != nil {
            self.dataSource!(state)
        }
        self.updateContentViewLayout()
    }
}

extension GXRefreshCustomFooter {
    func setFooterText(_ text: String, for state: GXRefreshComponent.State) {
        self.footerTexts.updateValue(text, forKey: state)
        if self.state == state {
            self.textLabel.text = text
        }
    }
}
