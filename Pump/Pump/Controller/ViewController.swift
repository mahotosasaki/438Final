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

var userID:String = ""
var USERNAME: String = " "

class ViewController: UIViewController {

    let db = Firestore.firestore()
    var followingUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //CoreDataFunctions.deleteAllData()
        // Do any additional setup after loading the view.
    }
    
    


}

