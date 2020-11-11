//
//  TabViewController.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/11/11.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit
import GXSegmentPageView

class TabViewController: UIViewController {
    @IBOutlet weak var titleView: GXSegmentTitleView!
    @IBOutlet weak var pageView: GXSegmentPageView!

    private lazy var items: [String] = {
        return ["要闻", "推荐", "抗肺炎", "视频", "新时代",
                "娱乐", "体育", "军事", "小视频", "微天下"]
    }()
    
    private lazy var childVCs: [UIViewController] = {
        var children: [UIViewController] = []
        for (index, title) in self.items.enumerated() {
            let vc: TableViewController = TableViewController(nibName: "TableViewController", bundle: nil)
            vc.title = title
            children.append(vc)
        }
        return children
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = GXSegmentTitleView.Configuration()
        config.positionStyle = .bottom
        config.indicatorStyle = .dynamic
        config.indicatorFixedWidth = 30.0
        config.indicatorFixedHeight = 2.0
        config.indicatorAdditionWidthMargin = 5.0
        config.indicatorAdditionHeightMargin = 2.0
        config.isShowSeparator = false
        self.titleView.delegate = self
        self.titleView.setupSegmentTitleView(config: config, titles: self.items)

        self.pageView.delegate = self
        self.pageView.setupSegmentPageView(parent: self, children: childVCs)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension TabViewController: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        NSLog("select = %d, will = %d, progress = %f", page.selectedIndex, page.willSelectedIndex, progress)
        self.titleView.setSegmentTitleView(selectIndex: page.selectedIndex, willSelectIndex: page.willSelectedIndex, progress: progress)
    }
}

extension TabViewController: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}
