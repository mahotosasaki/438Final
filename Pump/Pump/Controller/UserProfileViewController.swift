//
//  UserProfileViewController.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/11/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class UserProfileViewController: UIViewController {
    let db = Firestore.firestore()
    
    var userProfile: User!
    var profilePosts: [Post] = []
    var userFollowing: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameLabel.text = userProfile.username
        // Do any additional setup after loading the view.
        fetchUserPosts()
    }

    
    @IBAction func followUser(_ sender: UIButton) {
       DispatchQueue.global().async {
            do {
                  let results = self.db.collection("users").whereField("uid", isEqualTo: userID)
                    results.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        for document in querySnapshot!.documents{
                            var userInfo: User?
                            try? userInfo = document.data(as:User.self)
                            self.userFollowing = userInfo?.following ?? User(experience: "err", following: [], height: 0, name: "err", profile_pic: "err", uid: "err", username: "err", weight: 0, email: "err").following!
                        }
                    }
                    DispatchQueue.main.async {
                        if self.userFollowing.contains(self.userProfile.uid) {}
                        else {
                            self.userFollowing.append(self.userProfile.uid)
                            self.db.collection("users").document(userID).setData([ "following": self.userFollowing], merge: true)
                            print (self.userFollowing)
                        }
                    }
                }
            }
        }
    }

    @IBOutlet weak var usernameLabel: UILabel!
    
    
    func fetchUserPosts() {
        DispatchQueue.global().async {
            do {
                let postsRef = self.db.collection("posts")
                
                let results = postsRef.whereField("userId", isEqualTo: self.userProfile?.uid)
                results.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                           // print(document.data().map(String.init(describing:)) ?? "nil")
                            var postInfo: Post?
                            try? postInfo = document.data(as:Post.self)
                            //print(postInfo)
                            self.profilePosts.append(postInfo ?? Post(id: "", exercises: [], likes: 0, title: "err", userId: "err"))
                        }
                    }
                    
                    DispatchQueue.main.async {
                        print(self.profilePosts)
                       
                    }
                }
            }
        }
    }

}
