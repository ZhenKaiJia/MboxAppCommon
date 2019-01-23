//
//  ViewController.swift
//  MboxAppCommon
//
//  Created by ZhenKaiJia on 01/21/2019.
//  Copyright (c) 2019 ZhenKaiJia. All rights reserved.
//

import UIKit
import MboxAppCommon

class ViewController: UIViewController {

    let tableView = MboxTableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = self.view.frame
        self.view.addSubview(tableView)


    }

    func setup() {
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

