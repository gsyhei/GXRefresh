//
//  GXRefreshGifHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/13.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXRefreshGifHeader: GXRefreshBaseHeader {
    open var isHiddenText: Bool = false
    
    private lazy var headerTexts: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "下拉刷新",
                .pulling: "下拉可以刷新",
                .will: "放开立即刷新",
                .did: "正在刷新...",
                .end: "刷新完成"]
    }()
    
    private lazy var headerImages: Dictionary<GXRefreshComponent.State, Array<UIImage>> = {
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
            if let images = self.headerImages[.pulling] {
                var index: Int = Int(ceil(CGFloat(images.count) * self.pullingProgress))
                if (index >= images.count) {
                    index = images.count - 1
                }
                self.imageView.image = images[index]
            }
        }
    }
}

fileprivate extension GXRefreshGifHeader {
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
        if let text = self.headerTexts[state] {
            self.textLabel.text = text
        }
        if state != .pulling {
            if let images = self.headerImages[state] {
                let image = images.first
                if images.count == 1 {
                    self.imageView.image = image
                    self.imageView.animationImages = nil
                }
                else {
                    self.imageView.image = nil
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
            else if state == .end {
                self.imageView.image = nil
                self.imageView.animationImages = nil
            }
        }
        self.updateContentViewLayout()
    }
}

extension GXRefreshGifHeader {
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
        if state == .did || state == .end {
            if (self.imageView.animationImages?.count ?? 0) > 1 {
                self.imageView.startAnimating()
            }
        }
        else {
            self.imageView.stopAnimating()
        }
    }
}

extension GXRefreshGifHeader {
    func setHeaderText(_ text: String, for state: GXRefreshComponent.State) {
        self.headerTexts.updateValue(text, forKey: state)
        self.updateContentView(state: state)
    }
    func setHeaderImages(_ imageNames: Array<String>, duration: TimeInterval? = nil, for state: GXRefreshComponent.State) {
        guard imageNames.count > 0 else { return }
        var images:[UIImage] = []
        for name in imageNames {
            let image = UIImage(named: name)
            if image != nil {
                images.append(image!)
            }
        }
        guard images.count > 0 else { return }
        self.headerImages.updateValue(images, forKey: state)
        if (duration != nil) {
            self.stateDuration.updateValue(duration!, forKey: state)
        }
        self.updateContentView(state: state)
    }
    func setHeaderImages(_ images: Array<UIImage>, duration: TimeInterval? = nil, for state: GXRefreshComponent.State) {
        guard images.count > 0 else { return }
        self.headerImages.updateValue(images, forKey: state)
        if (duration != nil) {
            self.stateDuration.updateValue(duration!, forKey: state)
        }
        self.updateContentView(state: state)
    }
}
