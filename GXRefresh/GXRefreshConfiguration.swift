//
//  GXRefreshConfiguration.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/9.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit
import AudioToolbox

class GXRefreshConfiguration: NSObject {
    static let shared: GXRefreshConfiguration = {
        let instance = GXRefreshConfiguration()
        return instance
    }()
    
    open var isPlayImpact: Bool = true

    open var animationDuration: TimeInterval = 0.25
    
    open var enRefreshDelay: TimeInterval = 0.5
    
    open var headerHeight: CGFloat = 54.0
    
    open var footerHeight: CGFloat = 44.0
    
    open lazy var headerTextDict: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "下拉刷新",
                .pulling: "下拉可以刷新",
                .will: "放开立即刷新",
                .did: "正在刷新...",
                .end: "刷新完成"]
    }()
    
    open lazy var footerTextDict: Dictionary<GXRefreshComponent.State, String> = {
        return [.idle: "点击或上拉加载更多",
                .pulling: "上拉加载更多",
                .will: "放开立即加载更多",
                .did: "正在加载更多数据...",
                .noMore: "已加载全部数据"]
    }()
}

extension GXRefreshConfiguration {
    func playImpact() {
        guard self.isPlayImpact else { return }
        AudioServicesPlaySystemSound(1519)
    }
    func setHeaderText(_ text: String, for state: GXRefreshComponent.State) {
        self.headerTextDict.updateValue(text, forKey: state)
    }
    func setFooterText(_ text: String, for state: GXRefreshComponent.State) {
        self.footerTextDict.updateValue(text, forKey: state)
    }
}
