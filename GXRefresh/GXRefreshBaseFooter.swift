//
//  GXRefreshBaseFooter.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/11.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public class GXRefreshBaseFooter: GXRefreshComponent {
    /// state下需要重写或自行增加的数据
    open var dataSource: ((_ state: State) -> Void)? = nil
    /// 刷新文本是否隐藏
    open var isTextHidden: Bool = false
    /// 没有更多数据的情况下内容超出屏幕是否隐藏footer
    open var isHiddenNoMoreByContent: Bool = true
    /// 是否开启自动刷新
    open var automaticallyRefresh: Bool = true
    /// 上拉需要的百分比（下拉到多少刷新）
    open var automaticallyRefreshPercent: CGFloat = 1.0
    /// 刷新页脚高度
    open var footerHeight: CGFloat = 44.0 {
        didSet {
            self.gx_height = self.footerHeight
        }
    }
    /// 指示器与文本的间隔
    open var textToIndicatorSpacing: CGFloat = 10.0 {
        didSet {
            self.updateContentViewLayout()
        }
    }
    /// 自定指示器内容
    open var customIndicator: UIView {
        return UIView()
    }
    /// 刷新文本label
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    /// 刷新文本
    private(set) lazy var refreshTitles: Dictionary<State, String> = {
        return [.idle: "点击或上拉加载更多",
                .pulling: "上拉加载更多",
                .will: "放开立即加载更多",
                .did: "正在加载更多数据...",
                .noMore: "已加载全部数据"]
    }()
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard !self.isHidden && self.scrollView != nil else { return }
        
        var contentInset = self.svContentInset
        contentInset.bottom = self.scrollViewOriginalInset.bottom + self.gx_height
        self.scrollView?.contentInset = contentInset
    }
}

public extension GXRefreshBaseFooter {
    override func prepare() {
        super.prepare()
        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
        self.gx_height = self.footerHeight
        self.contentView.addSubview(self.customIndicator)
        self.contentView.addSubview(self.textLabel)
        self.contentView.addTarget(self, action: #selector(self.contentClicked(_:)), for: .touchUpInside)
        self.updateContentView(state: .idle)
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = self.svContentHeight() + self.scrollViewOriginalInset.bottom
        
        var contentInset = self.svContentInset
        if self.automaticallyRefresh {
            contentInset.bottom = self.scrollViewOriginalInset.bottom + self.gx_height
            self.scrollView?.contentInset = contentInset
        } else {
            contentInset.bottom = self.scrollViewOriginalInset.bottom
            self.scrollView?.contentInset = contentInset
        }
        self.updateContentViewLayout()
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        // did/end/noMore状态下跳过
        let headerRefreshing: Bool = self.scrollView?.gx_header?.isRefreshing ?? false
        guard !self.isRefreshing && !headerRefreshing else { return }
        // 获取scrollView.offset
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 需要内容超过屏幕
            guard self.isContentBeyondScreen() || !self.automaticallyRefresh else { return }
            // 判断header是否出现
            var justOffsetY = self.svContentHeight() + self.svAdjustedInset.bottom
            if self.automaticallyRefresh {
                justOffsetY -= (self.scrollView!.gx_height + self.gx_height)
            }
            else {
                justOffsetY -= self.scrollView!.gx_height
            }
            guard offset.y >= justOffsetY else { return }
            // 需要拉到刷新的offsetY
            let footerHeight = self.gx_height * self.automaticallyRefreshPercent
            let pullingOffsetY = justOffsetY + footerHeight
            // 刷新头部视图透明百分比进度
            let pullingProgress: CGFloat = (offset.y - justOffsetY) / footerHeight
            self.pullingProgress = pullingProgress
            // 自动刷新是否开启
            if self.automaticallyRefresh {
                if self.state == .idle && offset.y >= pullingOffsetY {
                    self.state = .did
                }
            }
            else {
                // 判断是否正在拖拽
                if self.scrollView!.isDragging && self.scrollView!.isTracking {
                    if ((self.state == .idle || self.state == .will) && offset.y < pullingOffsetY) {
                        self.state = .pulling
                    }
                    else if (self.state == .pulling && offset.y >= pullingOffsetY) {
                        self.state = .will
                    }
                }
                else {
                    if self.state == .will {
                        self.state = .did
                    }
                    else if self.state != .noMore {
                        self.state = .idle
                    }
                }
            }
        }
    }
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
        self.isHidden = (self.svContentSize.height == 0)
        // 有内容才进行设置
        guard (self.scrollView!.gx_height > 0) else { return }
        self.gx_top = self.svContentHeight() + self.scrollViewOriginalInset.bottom
        // 内容没有超出屏幕
        guard !self.isContentBeyondScreen() else { return }
        self.alpha = 1.0
        self.isHidden = self.isHiddenNoMoreByContent && (self.state == .noMore)
    }
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
        // 需要内容小于屏幕
        guard self.automaticallyRefresh && !self.isContentBeyondScreen() else { return }
        guard self.state == .idle else { return }
        if let panState = change?[NSKeyValueChangeKey.newKey] as? Int {
            // state == .ended
            guard (panState == UIGestureRecognizer.State.ended.rawValue) else { return }
            if (self.svContentOffset.y > -self.svAdjustedInset.top) {
                self.state = .did
            }
        }
    }
    override func setState(_ state: State) {
        super.setState(state)
        if state == .did {
            self.didStateRefreshing()
        }
        else if state == .end {
            self.endStateRefreshing()
        }
        else if state == .noMore {
            self.endStateRefreshing(isNoMore: true)
        }
        self.updateContentView(state: state)
    }
}

fileprivate extension GXRefreshBaseFooter {
    func svContentHeight() -> CGFloat {
        if !self.automaticallyRefresh && !self.isContentBeyondScreen() {
            return (self.scrollView!.gx_height - self.svAdjustedInset.top - self.svAdjustedInset.bottom)
        }
        return self.svContentSize.height
    }
    func isContentBeyondScreen() -> Bool {
        let contentH = self.svContentSize.height + self.scrollViewOriginalInset.top + self.scrollViewOriginalInset.bottom
        return (contentH >= self.scrollView!.gx_height)
    }
    func didStateRefreshing() {
        if !self.automaticallyRefresh {
            var contentInset = self.svContentInset
            contentInset.bottom = self.scrollViewOriginalInset.bottom + self.gx_height
            var contentOffset = self.svContentOffset
            if !self.isContentBeyondScreen() {
                contentOffset.y -= self.gx_height
            }
            self.scrollView?.contentInset = contentInset
            self.scrollView?.contentOffset = contentOffset
        }
        if self.automaticallyChangeAlpha {
            self.alpha = 1.0
        }
        if self.refreshingAction != nil {
            self.refreshingAction!()
        }
        if self.beginRefreshingAction != nil {
            self.beginRefreshingAction!()
        }
    }
    func endStateRefreshing(isNoMore: Bool = false) {
        if !self.automaticallyRefresh {
            var contentInset = self.svContentInset
            contentInset.bottom = self.scrollViewOriginalInset.bottom
            self.scrollView?.contentInset = contentInset
        }
        if !isNoMore {
            self.state = .idle
        }
        if self.automaticallyChangeAlpha && isContentBeyondScreen() {
            self.alpha = 0.0
        }
        if self.endRefreshingAction != nil {
            self.endRefreshingAction!()
        }
    }
    @objc func contentClicked(_ sender: UIControl) {
        guard self.state == .idle else { return }
        self.beginRefreshing()
    }
}

public extension GXRefreshBaseFooter {
    func beginRefreshing() {
        self.state = .did
    }
    func endRefreshing(isNoMore: Bool = false) {
        self.state = isNoMore ? .noMore : .end
    }
    func updateContentViewLayout() {
        self.textLabel.isHidden =  self.isTextHidden
        if self.isTextHidden {
            self.customIndicator.center = self.contentView.center
        }
        else {
            let nsText: NSString = (self.textLabel.text ?? "") as NSString
            let maxSize = self.contentView.bounds.size
            let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let attributes: [NSAttributedString.Key : Any] = [.font : self.textLabel.font!]
            let rect = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
            self.textLabel.frame = rect
            self.textLabel.center = CGPoint(x: self.contentView.gx_width/2, y: self.contentView.gx_height/2)
            self.customIndicator.center.y = self.textLabel.center.y
            self.customIndicator.gx_right = self.textLabel.gx_left - self.textToIndicatorSpacing
        }
    }
    func updateContentView(state: State) {
        if let text = self.refreshTitles[state] {
            self.textLabel.text = text
        }
        if self.dataSource != nil {
            self.dataSource!(state)
        }
        self.updateContentViewLayout()
    }
    func setRefreshTitles(_ text: String, for state: State) {
        self.refreshTitles.updateValue(text, forKey: state)
        if self.state == state {
            self.textLabel.text = text
        }
    }
}
