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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        self.tableView.gx_header = GXRefreshNormalHeader(refreshingAction: { [weak self] in
            self?.refreshDataSource()
        })
        self.tableView.gx_header?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        self.tableView.gx_footer = GXRefreshNormalFooter(refreshingAction: { [weak self] in
            self?.loadMoreData()
        })
        self.tableView.gx_footer?.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    
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
            self.tableView.gx_footer?.endRefreshing()
        }
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
        
//        self.tableView.gx_header?.beginRefreshing()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.tableView.gx_header?.endRefreshing()
//        }
        
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

