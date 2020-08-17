//
//  ViewController.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/9.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var cellNumber: Int = 30
    public var refreshStyle: Int = 0
    
    private var headerLoadView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "refresh30"))
        return view
    }()
    private var footerLoadView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "refresh30"))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        self.setupRefrsh()
    }
    
    func setupRefrsh() {
        if self.refreshStyle == 0 {
            self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
                self?.refreshDataSource()
            })
            self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
                self?.loadMoreData()
            })
        }
        else if self.refreshStyle == 1 {
            var imageNames: [String] = []
            for i in 0..<31 {
                imageNames.append(String(format: "refresh%d", i))
            }
            let header = GXRefreshGifHeader(completion: { [weak self] in
                self?.refreshDataSource()
            })
            header.isShowEndRefresh = false
            header.setRefreshImages([imageNames.first!], for: .idle)
            header.setRefreshImages(imageNames, for: .pulling)
            header.setRefreshImages(imageNames, duration: 2.0, for: .did)
            header.setRefreshImages([imageNames.last!], for: .end)
            self.tableView.gx_header = header
            self.tableView.gx_header?.backgroundColor = UIColor(white: 0.95, alpha: 1)
            
            let footer = GXRefreshGifFooter(completion: { [weak self] in
                self?.loadMoreData()
            })
            footer.setRefreshImages([imageNames[21]], for: .idle)
            footer.setRefreshImages(imageNames, duration: 2.0, for: .did)
            footer.setRefreshImages([imageNames.last!], for: .noMore)
            self.tableView.gx_footer = footer
        }
        else if self.refreshStyle == 2 {
            let header = GXRefreshCustomHeader(completion: { [weak self] in
                self?.refreshDataSource()
            })
            header.isTextHidden = true
            header.isShowEndRefresh = false
            header.updateCustomIndicator(view: self.headerLoadView)
            header.progressCallBack = { (view) in
                let angle = self.rotationAngle(progress: view.pullingProgress)
                self.headerLoadView.transform = CGAffineTransform(rotationAngle: angle)
            }
            header.stateCallBack = { (state) in
                if state == .did {
                    self.headerLoadView.layer.add(self.rotationAnimation(), forKey: nil)
                }
                else {
                    self.headerLoadView.transform = .identity
                    self.headerLoadView.layer.removeAllAnimations()
                }
            }
            self.tableView.gx_header = header
            
            
            let footer = GXRefreshCustomFooter(completion: { [weak self] in
                self?.loadMoreData()
            })
            footer.updateCustomIndicator(view: self.footerLoadView)
            footer.progressCallBack = { (view) in
                let angle = self.rotationAngle(progress: view.pullingProgress)
                self.footerLoadView.transform = CGAffineTransform(rotationAngle: angle)
            }
            footer.stateCallBack = { (state) in
                if state == .did {
                    self.footerLoadView.layer.add(self.rotationAnimation(), forKey: nil)
                }
                else {
                    self.footerLoadView.transform = .identity
                    self.footerLoadView.layer.removeAllAnimations()
                }
            }
            self.tableView.gx_footer = footer
        }
        
        self.tableView.gx_header?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.tableView.gx_footer?.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
}

fileprivate extension ViewController {
    func refreshDataSource() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.cellNumber = 10
            self.tableView.reloadData()
            self.tableView.gx_header?.endRefreshing()
        }
    }
    func loadMoreData() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.cellNumber += 10
            self.tableView.reloadData()
            
            if self.cellNumber == 30 {
                self.tableView.gx_footer?.endRefreshing(isNoMore: true)
            }
            else {
                self.tableView.gx_footer?.endRefreshing()
            }
        }
    }
    func rotationAngle(progress: CGFloat) -> CGFloat {
        var newProgress = progress
        if progress < 0 {
            newProgress = 0
        }
        else if (progress > 1) {
            newProgress = 1
        }
        let angle = newProgress * 360
        return (angle / 180.0 * CGFloat.pi)
    }

    func rotationAnimation() -> CABasicAnimation {
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = 0
        rotationAnim.toValue = Double.pi * 2
        rotationAnim.repeatCount = 1000
        rotationAnim.duration = 0.5
        rotationAnim.autoreverses = false
        rotationAnim.isRemovedOnCompletion = false
        
        return rotationAnim
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellID = "cellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: CellID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: CellID)
        }
        cell?.textLabel?.text = "Cell " + String(indexPath.row)
        cell?.detailTextLabel?.text = "detailText"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 11.0, *) {
            NSLog("safeAreaInsets = %@", NSCoder.string(for: self.tableView.safeAreaInsets))
            NSLog("adjustedContentInset = %@", NSCoder.string(for: self.tableView.adjustedContentInset))
        }
        NSLog("contentInset = %@", NSCoder.string(for: self.tableView.contentInset))
        NSLog("alignmentRectInsets = %@", NSCoder.string(for: self.tableView.alignmentRectInsets))
        NSLog("contentOffset = %@", NSCoder.string(for: self.tableView.contentOffset))
        NSLog("contentSize = %@", NSCoder.string(for: self.tableView.contentSize))
        NSLog("bounds = %@", NSCoder.string(for: self.tableView.bounds))
        NSLog("view bounds = %@", NSCoder.string(for: self.view.bounds))
        
    }
}

