//
//  TableViewController.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/11/11.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    private var cellNumber: Int = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.refreshDataSource()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.loadMoreData()
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cellNumber
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellID = "cellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: CellID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: CellID)
        }
        cell?.textLabel?.text = "Cell " + String(indexPath.row)
        cell?.detailTextLabel?.text = "detailText"

        return cell!
    }
}

fileprivate extension TableViewController {
    func refreshDataSource() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.cellNumber = 10
            self.tableView.reloadData()
            
            self.tableView.gx_header?.endRefreshing(isSucceed: true, text: nil)
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
}
