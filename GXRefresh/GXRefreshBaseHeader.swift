//
//  GXRefreshBaseHeaderView.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/10.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit
import AudioToolbox

public class GXRefreshBaseHeader: GXRefreshComponent {
    /// state下需要重写或自行增加的数据
    open var dataSource: ((_ state: State) -> Void)? = nil
    /// 刷新文本是否隐藏
    open var isTextHidden: Bool = false
    /// 下拉到刷新状态是否有震动
    open var isPlayImpact: Bool = true
    /// 与scrollView相关的动画时间
    open var animationDuration: TimeInterval = 0.25
    /// 结束刷新动画执行时间
    open var endRefreshDuration: TimeInterval = 0.7
    /// 结束刷新完成后的停留时间
    open var endRefreshDelay: TimeInterval = 0.5
    /// 刷新下拉需要的百分比（下拉到多少刷新）
    open var automaticallyRefreshPercent: CGFloat = 1.0
    /// 刷新头部高度
    open var headerHeight: CGFloat = 54.0 {
        didSet {
            self.gx_height = self.headerHeight
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
        return [.idle: "下拉刷新",
                .pulling: "下拉可以刷新",
                .will: "放开立即刷新",
                .did: "正在刷新...",
                .end: "刷新完成"]
    }()
    /// 刷新结束动画相关
    private(set) var isShowEndAnimated: Bool = true
    private var isRefreshSucceed: Bool = true
    private var isOriginalTextHidden: Bool = true
    private var endRefreshText: String?
    /// 震动相关
    private var isPlayingImpact: Bool = false
    @available(iOS 10.0, *)
    private lazy var generator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .light)
    }()
}

public extension GXRefreshBaseHeader {
    override func prepare() {
        super.prepare()
        self.alpha = self.automaticallyChangeAlpha ? 0 : 1
        self.gx_height = self.headerHeight
        self.contentView.addSubview(self.customIndicator)
        self.contentView.addSubview(self.textLabel)
        self.updateContentView(state: .idle)
    }
    override func prepareLayoutSubviews() {
        super.prepareLayoutSubviews()
        self.gx_top = -(self.gx_height + self.svContentInset.top)
        self.updateContentViewLayout()
    }
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        // did/end状态的情况
        guard self.state != .did && self.state != .end else { return }
        // 获取scrollView.offset
        if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            // 判断header是否出现
            let justOffsetY = -self.svAdjustedInset.top
            guard offset.y < justOffsetY else {
                if (self.state == .pulling) {
                    // 设置回到看不见就重置震动播放
                    self.isPlayingImpact = false
                }
                return
            }
            // 需要拉到刷新的offsetY
            let headerHeight = self.gx_height * self.automaticallyRefreshPercent
            let pullingOffsetY = justOffsetY - headerHeight
            // 刷新头部视图透明百分比进度
            let pullingProgress: CGFloat = (justOffsetY - offset.y) / headerHeight
            self.pullingProgress = pullingProgress
            // 判断是否正在拖拽
            if self.scrollView!.isDragging && self.scrollView!.isTracking {
                if ((self.state == .idle || self.state == .will) && offset.y > pullingOffsetY) {
                    self.state = .pulling
                }
                else if (self.state == .pulling && offset.y <= pullingOffsetY) {
                    self.state = .will
                    if !self.isPlayingImpact {
                        self.isPlayingImpact = true
                        self.playImpact()
                    }
                }
            }
            else {
                if self.state == .will {
                    self.state = .did
                }
                else if (offset.y <= pullingOffsetY) {
                    self.state = .idle
                }
            }
        }
    }
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
    }
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
    }
    override func setState(_ state: State) {
        super.setState(state)
        self.updateContentView(state: state)
        if state == .did {
            self.didStateRefreshing()
        }
        else if state == .end {
            if self.isShowEndAnimated {
                GXRefreshIndicatorView.show(to: self.contentView,
                                            strokeColor: self.textLabel.textColor,
                                            animationDuration: self.endRefreshDuration,
                                            center: self.customIndicator.center,
                                            isSucceed: self.isRefreshSucceed)
                {
                    self.didStateEndRefreshing()
                }
            }
            else {
                self.didStateEndRefreshing()
            }
        }
    }
}

fileprivate extension GXRefreshBaseHeader {
    func setTefreshTextLabel(for state: State) {
        if state == .end && self.endRefreshText != nil {
            self.textLabel.text = self.endRefreshText
        }
        else if let text = self.refreshTitles[state] {
            self.textLabel.text = text
        }
    }
    func playImpact() {
        guard self.isPlayImpact else { return }
        if #available(iOS 10.0, *) {
            self.generator.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1519)
        }
    }
    func didStateRefreshing() {
        var contentOffset = self.svContentOffset
        var contentInset = self.svContentInset
        let headerHeight = self.gx_height * self.automaticallyRefreshPercent
        contentInset.top = self.scrollViewOriginalInset.top + headerHeight
        if self.oldState == .idle {
            contentOffset.y -= headerHeight
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.scrollView?.contentInset = contentInset
                self.scrollView?.contentOffset = contentOffset
                if self.automaticallyChangeAlpha {
                    self.alpha = 1.0
                }
            }) { (finish) in
                if self.refreshingAction != nil {
                    self.refreshingAction!()
                }
                if self.beginRefreshingAction != nil {
                    self.beginRefreshingAction!()
                }
            }
        }
        else {
            self.scrollView?.contentInset = contentInset
            self.scrollView?.contentOffset = contentOffset
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
    }
    func didStateEndRefreshing() {
        if !self.isShowEndAnimated {
            self.state = .idle
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+self.endRefreshDelay) {
            self.endStateRefreshing()
        }
    }
    func endStateRefreshing() {
        var contentInset = self.svContentInset
        contentInset.top = self.scrollViewOriginalInset.top
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.scrollView?.contentInset = contentInset
            if self.automaticallyChangeAlpha {
                self.alpha = 0.0
            }
        }) { (finished) in
            self.state = .idle
            self.isPlayingImpact = false
            if self.isShowEndAnimated {
                self.isTextHidden = self.isOriginalTextHidden
                GXRefreshIndicatorView.hide(to: self.contentView)
            }
            if self.endRefreshingAction != nil {
                self.endRefreshingAction!()
            }
        }
    }
}

public extension GXRefreshBaseHeader {
    func beginRefreshing() {
        self.state = .did
    }
    func endRefreshing(isNoMore: Bool = false, isSucceed: Bool? = nil, text: String? = nil) {
        self.state = .end
        self.isShowEndAnimated = (isSucceed != nil)
        if self.isShowEndAnimated {
            self.isRefreshSucceed = isSucceed!
            self.endRefreshText = text
            self.isOriginalTextHidden = self.isTextHidden
            self.isTextHidden = false
        }
        self.scrollView?.gx_footer?.endRefreshing(isNoMore: isNoMore)
    }
    
    func updateContentViewLayout() {
        self.textLabel.isHidden = self.isTextHidden
        self.customIndicator.isHidden = (self.state == .end) && self.isShowEndAnimated
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
        self.setTefreshTextLabel(for: state)
        if self.dataSource != nil {
            self.dataSource!(state)
        }
        self.updateContentViewLayout()
    }
    func setRefreshTitles(_ text: String, for state: State) {
        self.refreshTitles.updateValue(text, forKey: state)
        if self.state == state {
            self.setTefreshTextLabel(for: state)
        }
    }
}
