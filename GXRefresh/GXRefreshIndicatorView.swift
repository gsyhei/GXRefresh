//
//  GXRefreshIndicatorView.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/16.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshIndicatorView: UIView {
    private var animationStopAction: GXRefreshComponent.GXRefreshCallBack? = nil
    private var lineWidth: CGFloat = 2.0
    private var strokeColor: UIColor = UIColor.blue
    private var animationDuration: TimeInterval = 0.7
    private var isSucceed: Bool = true

    private(set) lazy var animationLayer: CALayer = {
        let layer = CALayer()
        layer.frame = self.bounds
        self.layer.addSublayer(layer)
        return layer
    }()
}

public extension GXRefreshIndicatorView {
    class func show(to view: UIView,
                    lineWidth: CGFloat = 2.0,
                    strokeColor: UIColor = .blue,
                    animationDuration: TimeInterval = 0.7,
                    size: CGSize = CGSize(width: 22, height: 22),
                    center: CGPoint? = nil,
                    isSucceed: Bool = true,
                    completion:@escaping GXRefreshComponent.GXRefreshCallBack)
    {
        let indicator = GXRefreshIndicatorView(frame: CGRect(origin: .zero, size: size))
        if center != nil {
            indicator.center = center!
        } else {
            indicator.center = view.center
        }
        indicator.isSucceed = isSucceed
        indicator.lineWidth = lineWidth
        indicator.strokeColor = strokeColor
        indicator.animationDuration = animationDuration
        indicator.animationStopAction = completion
        indicator.startAnimation()
        view.addSubview(indicator)
    }
    
    class func hide(to view: UIView) {
        for subview in view.subviews {
            if subview.isKind(of: GXRefreshIndicatorView.self) {
                let indicator: GXRefreshIndicatorView = subview as! GXRefreshIndicatorView
                indicator.stopAnimation()
                indicator.removeFromSuperview()
            }
        }
    }
}

fileprivate extension GXRefreshIndicatorView {
    func circleAnimation() {
        let circleLayer: CAShapeLayer = CAShapeLayer()
        circleLayer.frame = self.animationLayer.bounds
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = self.strokeColor.cgColor
        circleLayer.lineWidth = self.lineWidth
        circleLayer.lineCap = .round
        self.animationLayer.addSublayer(circleLayer)

        let startAngle = -CGFloat.pi*0.5, endAngle = CGFloat.pi*1.5
        let radius = (self.animationLayer.frame.width - self.lineWidth) * 0.5
        let path = UIBezierPath.init(arcCenter: circleLayer.position, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.path = path.cgPath
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.isRemovedOnCompletion = false
        animation.duration = self.animationDuration * 0.8
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.delegate = self
        animation.setValue("circleAnimation", forKey: "animationName")
        circleLayer.add(animation, forKey: nil)
    }
    func checkAnimation() {
        let checkLayer: CAShapeLayer = CAShapeLayer()
        checkLayer.frame = self.animationLayer.bounds
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.strokeColor = self.strokeColor.cgColor
        checkLayer.lineWidth = self.lineWidth
        checkLayer.lineCap = .round
        checkLayer.lineJoin = .round
        self.animationLayer.addSublayer(checkLayer)

        let w = self.animationLayer.bounds.width
        let path = UIBezierPath()
        path.move(to: CGPoint(x: w * 0.27, y: w * 0.54))
        path.addLine(to: CGPoint(x: w * 0.45, y: w * 0.70))
        path.addLine(to: CGPoint(x: w * 0.78, y: w * 0.38))
        checkLayer.path = path.cgPath

        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.isRemovedOnCompletion = false
        animation.duration = self.animationDuration * 0.4
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.delegate = self
        animation.setValue("endAnimation", forKey: "animationName")
        checkLayer.add(animation, forKey: nil)
    }
    func crossAnimation() {
        let checkLayer: CAShapeLayer = CAShapeLayer()
        checkLayer.frame = self.animationLayer.bounds
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.strokeColor = self.strokeColor.cgColor
        checkLayer.lineWidth = self.lineWidth
        checkLayer.lineCap = .round
        checkLayer.lineJoin = .round
        self.animationLayer.addSublayer(checkLayer)

        let w = self.animationLayer.bounds.width
        let path = UIBezierPath()
        path.move(to: CGPoint(x: w * 0.28, y: w * 0.28))
        path.addLine(to: CGPoint(x: w * 0.72, y: w * 0.72))
        path.move(to: CGPoint(x: w * 0.72, y: w * 0.28))
        path.addLine(to: CGPoint(x: w * 0.28, y: w * 0.72))
        checkLayer.path = path.cgPath
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.isRemovedOnCompletion = false
        animation.duration = self.animationDuration * 0.4
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.delegate = self
        animation.setValue("endAnimation", forKey: "animationName")
        checkLayer.add(animation, forKey: nil)
    }
    func startAnimation() {
        self.circleAnimation()
    }
    func stopAnimation() {
        if let sublayers = self.animationLayer.sublayers {
            for sublayer in sublayers {
                sublayer.removeAllAnimations()
                sublayer.removeFromSuperlayer()
            }
        }
    }
}

extension GXRefreshIndicatorView: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        if let value: String = anim.value(forKey: "animationName") as? String {
            if value == "circleAnimation" {
                DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration * 0.6) {
                    if self.isSucceed {
                        self.checkAnimation()
                    } else {
                        self.crossAnimation()
                    }
                }
            }
        }
    }
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let value: String = anim.value(forKey: "animationName") as? String {
            if value == "endAnimation" {
                if self.animationStopAction != nil {
                    self.animationStopAction!()
                }
            }
        }
    }
}
