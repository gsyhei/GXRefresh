//
//  RootTableViewController.swift
//  GXRefreshSample
//
//  Created by Gin on 2020/8/14.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: ViewController = segue.destination as! ViewController
        if segue.identifier == "normal" {
            vc.refreshStyle = 0
        }
        else if segue.identifier == "gif" {
            vc.refreshStyle = 1
        }
        else if segue.identifier == "custom" {
            vc.refreshStyle = 2
        }
    }
}
