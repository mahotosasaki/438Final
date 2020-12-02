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
import FirebaseFirestoreSwift

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    var notifications = [Notification]()
    //will need to change currUser to a user object once we figure out whos logged in
    var currUser = "testNotifications"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        myCell.textLabel!.text = " liked your post "
        return myCell
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func fetchNotifications () {
        print("in fetch")
        //need to get a query from our database for all the notifications "receiverId" which maps to our current users id but need to rethink structure before this works
        var notiStruct: Notification?
        let notificationRefs = db.collection("notifications")
        //will need to structure currUser differently and maybe reference a userobjects uid instead
        let call = notificationRefs.whereField("receiverId", isEqualTo: currUser)
        call.getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("No results: \(err)")
            
        } else {
            print("in call")
            for document in querySnapshot!.documents {
                print("in a doc in querysnapshot")
            try? notiStruct = document.data(as:Notification.self)
                self.notifications.append(notiStruct ?? Notification(postId: "err", receiverId: "err", senderId: "err"))
                print (notiStruct ?? "unknown error")
            }
            }
        }
        self.tableView.reloadData()
        self.setupTableView()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
    }
    
}
