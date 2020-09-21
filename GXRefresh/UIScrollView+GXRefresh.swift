//
//  UIScrollView+GXRefresh.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/9.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

private var GXRefreshHeaderKey = 0
private var GXRefreshFooterKey = 1

public extension UIScrollView {
    
    var gx_header: GXRefreshBaseHeader? {
        set {
            guard newValue != self.gx_header else { return }
            self.gx_header?.removeFromSuperview()
            if newValue != nil { self.insertSubview(newValue!, at: 0) }
            objc_setAssociatedObject(self, &GXRefreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &GXRefreshHeaderKey) as? GXRefreshBaseHeader
        }
    }
    
    var gx_footer: GXRefreshBaseFooter? {
        set {
            guard newValue != self.gx_footer else { return }
            self.gx_footer?.removeFromSuperview()
            if newValue != nil { self.insertSubview(newValue!, at: 0) }
            objc_setAssociatedObject(self, &GXRefreshFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &GXRefreshFooterKey) as? GXRefreshBaseFooter
        }
    }
}

public extension UIView {
    var gx_top: CGFloat {
        set {
            self.frame.origin.y = newValue
        }
        get {
            return self.frame.origin.y
        }
    }
    var gx_left: CGFloat {
        set {
            self.frame.origin.x = newValue
        }
        get {
            return self.frame.origin.x
        }
    }
    var gx_right: CGFloat {
        set {
            self.frame.origin.x = newValue - self.frame.width
        }
        get {
            return self.frame.origin.x + self.frame.width
        }
    }
    var gx_bottom: CGFloat {
        set {
            self.frame.origin.y = newValue - self.frame.height
        }
        get {
            return self.frame.origin.y + self.frame.height
        }
    }
    var gx_width: CGFloat {
        set {
            self.frame.size.width = newValue
        }
        get {
            return self.frame.width
        }
    }
    var gx_height: CGFloat {
        set {
            self.frame.size.height = newValue
        }
        get {
            return self.frame.height
        }
    }
}
