//
//  SearchViewController.swift
//  Pump
//
//  Created by Reshad Hamauon on 11/30/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //used as the list of users will need to change to a struct instead
    //but for now this will do just to test if we got data
    var listOfProfiles = [User]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        //appending username to list of results
        myCell.textLabel!.text = listOfProfiles[indexPath.row].username
        //maybe also add their profile picture to the cell?
        return myCell
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func searchUsers(_ sender: UITextField) {
        let db = Firestore.firestore()
        let search:String = sender.text ?? " "
        
        if (search == "") {}
        else {
        let userRefs = db.collection("users")
            let results = userRefs.order(by: "username").start(at: [search]).end(at: ["\u{f8ff}"])
        results.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("No results: \(err)")
                
            } else {
                self.listOfProfiles.removeAll()
                    for document in querySnapshot!.documents {
                        //print(" for result of \(search) :  \(document.documentID) => \(document.data())")
                        
                        //adding the username to the array if it starts with our search word
                        let res = document.data()["username"] as! String
                        if res.hasPrefix(search) {
                            var userInfo: User?
                            //the default is created when users don't have all their info filled out. might be a better way to structure this line tho rather than how i have it
                            try? userInfo = document.data(as:User.self)
                            self.listOfProfiles.append(userInfo ?? User(experience: "err", following: ["err"], height: 0, name: "err", profile_pic: "err", uid: "err", username: "err", weight: 0)) }
                    }
                //updating table
                self.tableView.reloadData()
                self.setupTableView()
                }
            }
            
        }
        
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
