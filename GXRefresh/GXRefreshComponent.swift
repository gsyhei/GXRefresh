//
//  GXRefreshBaseView.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/9.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

extension GXRefreshComponent {
    public typealias GXRefreshCallBack = () -> Void
    
    @objc enum State: Int {
        case idle    = 0
        case pulling = 1
        case will    = 2
        case did     = 3
        case end     = 4
        case noMore  = 5
    }
    enum KeyPath: String {
        case contentOffset = "contentOffset"
        case contentSize   = "contentSize"
        case panState      = "state"
    }
    var contentOffset: CGPoint {
        return self.scrollView?.contentOffset ?? .zero
    }
    var contentInset: UIEdgeInsets {
        return self.scrollView?.contentInset ?? .zero
    }
    var adjustedInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.scrollView?.adjustedContentInset ?? .zero
        } else {
            return self.scrollView?.contentInset ?? .zero
        }
    }
    var contentSize: CGSize {
        return self.scrollView?.contentSize ?? .zero
    }
}

protocol GXRefreshDelegate: NSObjectProtocol {
    func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?)
    func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?)
    func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?)
}

class GXRefreshComponent: UIView {
    open var scrollView: UIScrollView?
    open var scrollViewOriginalInset: UIEdgeInsets = .zero
    open var automaticallyChangeAlpha: Bool = true
    open var refreshingAction: GXRefreshCallBack? = nil
    open var beginRefreshingCompletionAction: GXRefreshCallBack? = nil
    open var endRefreshingCompletionAction: GXRefreshCallBack? = nil
    
    open lazy var contentView: UIControl = {
        let view = UIControl(frame: self.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    open var isRefreshing: Bool {
        return self.state == .did || self.state == .end
    }
    
    private(set) var oldState: State = .idle
    private var _state: State = .idle
    open var state: State {
        set {
            self.oldState = _state
            _state = newValue
            DispatchQueue.main.async {
                self.setState(newValue)
            }
        }
        get {
            return _state
        }
    }
    
    open var pullingProgress: CGFloat = 0.0 {
        didSet {
            guard !self.isRefreshing && self.automaticallyChangeAlpha else {
                return
            }
            var progress: CGFloat = self.pullingProgress
            progress = progress < 0 ? 0 : progress
            progress = progress > 1 ? 1 : progress
            self.alpha = progress
        }
    }
    
    required init(refreshingAction: @escaping GXRefreshCallBack, beginCompletion: GXRefreshCallBack? = nil, endCompletion: GXRefreshCallBack? = nil) {
        super.init(frame: .zero)
        self.refreshingAction = refreshingAction
        self.beginRefreshingCompletionAction = beginCompletion
        self.endRefreshingCompletionAction = endCompletion
        self.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.prepareLayoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.removeObservers()
        if let scrollView = newSuperview as? UIScrollView {
            scrollView.alwaysBounceVertical = true
            self.scrollView = scrollView
            self.scrollViewOriginalInset = scrollView.contentInset
            
            self.gx_left = scrollView.gx_left
            self.gx_width = scrollView.gx_width
            
            self.addObservers()
        }
        else if self.scrollViewOriginalInset != .zero  {
            self.scrollView?.contentInset = self.scrollViewOriginalInset
        }
    }
}

fileprivate extension GXRefreshComponent {
    func keyPath(_ keyPath: KeyPath) -> String {
        return keyPath.rawValue
    }
    func addObservers() {
        let options: NSKeyValueObservingOptions = [.old, .new]
        self.scrollView?.addObserver(self, forKeyPath: self.keyPath(.contentOffset), options: options, context: nil)
        self.scrollView?.addObserver(self, forKeyPath: self.keyPath(.contentSize), options: options, context: nil)
        self.scrollView?.panGestureRecognizer.addObserver(self, forKeyPath: self.keyPath(.panState), options: options, context: nil)
    }
    func removeObservers() {
        self.scrollView?.removeObserver(self, forKeyPath: self.keyPath(.contentOffset))
        self.scrollView?.removeObserver(self, forKeyPath: self.keyPath(.contentSize))
        self.scrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: self.keyPath(.panState))
    }
}

@objc extension GXRefreshComponent {
    open func prepare() {
        self.autoresizingMask = .flexibleWidth
        self.addSubview(self.contentView)
    }
    open func prepareLayoutSubviews() {}
    open func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {}
    open func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {}
    open func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {}
    open func setState(_ state: State) {}
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard self.isUserInteractionEnabled else { return }
        if keyPath == self.keyPath(.contentSize) {
            self.scrollViewContentSizeDidChange(change: change)
        }
        guard !self.isHidden else { return }
        if keyPath == self.keyPath(.contentOffset) {
            self.scrollViewContentOffsetDidChange(change: change)
        }
        else if keyPath == self.keyPath(.panState) {
            self.scrollViewPanStateDidChange(change: change)
        }
    }
}
