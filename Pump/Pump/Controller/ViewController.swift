//
//  ViewController.swift
//  Pump
//
//  Created by Mahoto Sasaki on 11/15/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData

// Global variables
var userID:String = ""
var USERNAME: String = " "

class ViewController: UIViewController {
    
    let db = Firestore.firestore()
    var followingUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //only run this if your device is not synced up with firebase
        //CoreDataFunctions.deleteAllData()
    }
    
    
    
    
}

