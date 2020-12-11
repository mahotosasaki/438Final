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
    var userProfile: User!
    var profilePosts: [Post] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameLabel.text = userProfile.username
        // Do any additional setup after loading the view.
        fetchUserPosts()
    }

    
    @IBAction func followUser(_ sender: UIButton) {
        /*
        //need to fix this so it gets your actual following list from core data when you sign in, this is a hardcoded example
        var followingList:[String] = []
        //adds that id to your following list
        followingList.append(userProfile.uid)
        db.collection("users").document(userID).setData([ "following": followingList], merge: true)*/
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
                            self.profilePosts.append(postInfo ?? Post(exercises: [], likes: 0, title: "err", userId: "err"))
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
