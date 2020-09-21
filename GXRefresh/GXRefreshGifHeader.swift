//
//  GXRefreshGifHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/13.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshGifHeader: GXRefreshBaseHeader {
    private(set) lazy var refreshImages: Dictionary<State, Array<UIImage>> = {
        return [:]
    }()
    private(set) lazy var stateDuration: Dictionary<State, TimeInterval> = {
        return [:]
    }()
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    public override var customIndicator: UIView {
        return self.imageView
    }
    public override var pullingProgress: CGFloat {
        didSet {
            if let images = self.refreshImages[.pulling] {
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
    func updateImageView(state: State) {
        guard state != .pulling else { return }
        if let images = self.refreshImages[state] {
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
    }
}

public extension GXRefreshGifHeader {
    override func prepare() {
        super.prepare()
        self.dataSource = { [weak self] (state) in
            self?.updateImageView(state: state)
        }
    }
    override func setState(_ state: State) {
        super.setState(state)
        
        if state == .did {
            if (self.imageView.animationImages?.count ?? 0) > 1 {
                self.imageView.animationRepeatCount = 0
                self.imageView.startAnimating()
            }
        }
        else if state == .end {
            if (self.imageView.animationImages?.count ?? 0) > 1 {
                self.imageView.animationRepeatCount = 1
                self.imageView.startAnimating()
            }
        }
        else {
            self.imageView.stopAnimating()
        }
    }
}

public extension GXRefreshGifHeader {
    func setRefreshImages(_ imageNames: Array<String>, duration: TimeInterval? = nil, for state: State) {
        guard imageNames.count > 0 else { return }
        var images:[UIImage] = []
        for name in imageNames {
            let image = UIImage(named: name)
            if image != nil {
                images.append(image!)
            }
        }
        guard images.count > 0 else { return }
        self.refreshImages.updateValue(images, forKey: state)
        if (duration != nil) {
            self.stateDuration.updateValue(duration!, forKey: state)
        }
        self.updateContentView(state: state)
    }
    func setRefreshImages(_ images: Array<UIImage>, duration: TimeInterval? = nil, for state: State) {
        guard images.count > 0 else { return }
        self.refreshImages.updateValue(images, forKey: state)
        if (duration != nil) {
            self.stateDuration.updateValue(duration!, forKey: state)
        }
        self.updateContentView(state: state)
    }
}
