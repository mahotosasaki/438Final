//
//  NotificationsViewController.swift
//  Pump
//
//  Created by Reshad Hamauon on 11/30/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notifications = [""]
    var curUser = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        //appending username to list of results
        myCell.textLabel!.text = " liked your post "
        //maybe also add their profile picture to the cell?
        return myCell
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func fetchNotifications () {
        self.tableView.reloadData()
        self.setupTableView()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
    }
    
}
