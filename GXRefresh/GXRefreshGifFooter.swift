//
//  GXRefreshGifFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/13.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshGifFooter: GXRefreshBaseFooter {
    open var isHiddenText: Bool = false
    
    private lazy var footerTexts: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "点击或上拉加载更多",
                .pulling: "上拉加载更多",
                .will: "放开立即加载更多",
                .did: "正在加载更多数据...",
                .noMore: "已加载全部数据"]
    }()
    private lazy var footerImages: Dictionary<GXRefreshComponent.State, Array<UIImage>> = {
        return [:]
    }()
    private lazy var stateDuration: Dictionary<GXRefreshComponent.State, TimeInterval> = {
        return [:]
    }()
    
    open lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(label)
        return label
    }()
    
    override var pullingProgress: CGFloat {
        didSet {
            if let images = self.footerImages[.pulling] {
                var index: Int = Int(ceil(CGFloat(images.count) * self.pullingProgress))
                if (index >= images.count) {
                    index = images.count - 1
                }
                self.imageView.image = images[index]
            }
        }
    }
}

fileprivate extension GXRefreshGifFooter {
    @objc func contentClicked(_ sender: UIControl) {
        self.beginRefreshing()
    }
    func updateContentViewLayout() {
        if self.isHiddenText {
            self.imageView.center = self.contentView.center
        }
        else {
            let nsText: NSString = (self.textLabel.text ?? "") as NSString
            let maxSize = self.bounds.size
            let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let attributes: [NSAttributedString.Key : Any] = [.font : self.textLabel.font!]
            let rect = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
            self.textLabel.frame = rect
            self.textLabel.center = self.contentView.center
            self.imageView.center.y = self.contentView.center.y
            self.imageView.gx_right = self.textLabel.gx_left - 5.0
        }
    }
    func updateContentView(state: State) {
        if let text = self.footerTexts[state] {
            self.textLabel.text = text
        }
        if state != .pulling {
            if let images = self.footerImages[state] {
                let image = images.first
                if images.count == 1 {
                    self.imageView.image = image
                }
                else {
                    self.imageView.animationImages = images
                    if let duration = self.stateDuration[state] {
                        self.imageView.animationDuration = duration
                    }
                }
                self.imageView.frame = CGRect(origin: .zero, size: image?.size ?? .zero)
                let imageHeight = image?.size.height ?? 0
                if (imageHeight > self.gx_height) {
                    self.gx_height = imageHeight
                }
            }
        }
        self.updateContentViewLayout()
    }
}

extension GXRefreshGifFooter {
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
            self.imageView.startAnimating()
        }
        else {
            self.imageView.stopAnimating()
        }
    }
}

extension GXRefreshGifFooter {
    func setFooterText(_ text: String, for state: GXRefreshComponent.State) {
        self.footerTexts.updateValue(text, forKey: state)
        self.updateContentView(state: state)
    }
    func setFooterImages(_ imageNames: Array<String>, duration: TimeInterval? = nil, for state: GXRefreshComponent.State) {
        guard imageNames.count > 0 else { return }
        var images:[UIImage] = []
        for name in imageNames {
            let image = UIImage(named: name)
            if image != nil {
                images.append(image!)
            }
        }
        guard images.count > 0 else { return }
        self.footerImages.updateValue(images, forKey: state)
        if (duration != nil) {
            self.stateDuration.updateValue(duration!, forKey: state)
        }
        self.updateContentView(state: state)
    }
    func setFooterImages(_ images: Array<UIImage>, duration: TimeInterval? = nil, for state: GXRefreshComponent.State) {
        guard images.count > 0 else { return }
        self.footerImages.updateValue(images, forKey: state)
        if (duration != nil) {
            self.stateDuration.updateValue(duration!, forKey: state)
        }
        self.updateContentView(state: state)
    }
}
