//
//  GXRefreshNormalHeader.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/12.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshNormalHeader: GXRefreshBaseHeader {
    open var arrowImage: UIImage? = nil {
        didSet {
            guard self.arrowImage == nil else { return }
            self.arrowView.image = self.arrowImage
        }
    }
    private(set) lazy var indicator: UIActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        let aiView = UIActivityIndicatorView(frame: frame)
        aiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if #available(iOS 13.0, *) {
            aiView.style = .medium
        } else {
            aiView.style = .gray
        }
        return aiView
    }()
    private(set) lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.isHidden = true
        imageView.image = UIImage(named: "gx_arrow", in: Bundle(for: GXRefreshNormalHeader.self), compatibleWith: nil)
        return imageView
    }()
    private var indicatorSize: CGSize = CGSize(width: 25, height: 25)
    private(set) lazy var customView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: self.indicatorSize))
        self.indicator.frame = view.bounds
        self.arrowView.frame = view.bounds
        view.addSubview(self.indicator)
        view.addSubview(self.arrowView)
        return view
    }()
    public override var customIndicator: UIView {
        return self.customView
    }
}

public extension GXRefreshNormalHeader {
    override func setState(_ state: State) {
        super.setState(state)

        switch state {
        case .pulling:
            self.updateArrowView(isDown: true)
        case .will:
            self.updateArrowView(isDown: false)
        case .did:
            self.arrowView.isHidden = true
            self.customIndicator.frame.size = self.indicatorSize
            self.updateContentViewLayout()
            self.indicator.startAnimating()
        case .end:
            self.indicator.stopAnimating()
        default: break
        }
    }
    private func updateArrowView(isDown: Bool) {
        self.arrowView.isHidden = false
        self.customIndicator.frame.size = self.arrowView.image?.size ?? .zero
        self.updateContentViewLayout()
        if isDown {
            if self.arrowView.transform != .identity {
                UIView.animate(withDuration: self.animationDuration) {
                    self.arrowView.transform = .identity
                }
            }
        }
        else {
            if self.arrowView.transform == .identity {
                let angle = CGFloat.pi-0.00001
                UIView.animate(withDuration: self.animationDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
    }
}
