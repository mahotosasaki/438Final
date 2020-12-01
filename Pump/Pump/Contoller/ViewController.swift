//
//  ViewController.swift
//  Pump
//
//  Created by Mahoto Sasaki on 11/15/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import FirebaseFirestore
class ViewController: UIViewController {

    struct User: Codable {
        var experience: String
        var following: [String]
        var height: Double
        var name: String
        var profile_pic: String
        var uid: Int
        var username: String
        var weight: Double
        
    }
    
    struct Post: Codable {
        var exercises: [Exercise]
        var likes: Int
        var title: String
        var userId: String
    }
    
    struct Notification: Codable {
        var postId: String
        var recieverId: String
        var senderId: String
    }
    
    struct Exercise: Codable {
        var exerciseName: String
        var reps: Int
        var sets: Int
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        
        
       
        
        
    }


}

