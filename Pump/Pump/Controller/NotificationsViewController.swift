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

class NotificationsViewController: UIViewController {
    
    let db = Firestore.firestore()
    var notifications = [Notification]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notifications = []
        fetchNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if (segue.identifier == "toDetailedWorkout") {
        //
        //            let detailedPostView = segue.destination as? DetailedWorkoutController
        //            detailedPostView?.postId = sender as! String
        //        }
        if(segue.identifier == "toDetailedWorkoutViewController") {
            let detailedPostView = segue.destination as? DetailedPostViewController
            detailedPostView?.postId = sender as? String
            detailedPostView?.uniqueSegueIdentifier = "No Like Button"
        }
    }
    
    func fetchNotifications () {
        DispatchQueue.global().async {
            do {
                var notiStruct: Notification?
                let notificationRefs = self.db.collection("notifications")
                let call = notificationRefs.whereField("receiverId", isEqualTo: userID)
                call.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            try? notiStruct = document.data(as:Notification.self)
                            self.notifications.append(notiStruct ?? Notification(postId: "err", postTitle: "err", receiverId: "err", senderId: "err"))
                            //print (notiStruct ?? "unknown error")
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate{
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        var senderName:String?
        let senderCall = db.collection("users").document(notifications[indexPath.row].senderId)
        DispatchQueue.global().async {
            do {
                senderCall.getDocument{ (document, error) in
                    if let document = document, document.exists {
                        senderName = document.data()?["username"] as? String
                        DispatchQueue.main.async {
                            guard let senderNameGuarded = senderName else {
                                return
                            }
                            myCell.textLabel!.text = "\(senderNameGuarded) liked your post \(self.notifications[indexPath.row].postTitle)"
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetailedWorkoutViewController", sender: notifications[indexPath.row].postId)
    }
}
