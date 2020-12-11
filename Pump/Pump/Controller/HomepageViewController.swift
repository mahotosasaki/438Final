//
//  HomepageViewController.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/10/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
class HomepageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var workoutCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
    
    //this is hardcoded, needs to be the actual following list which probably needs to be pulled from coredata
    var userFollowing: [String] = ["X8NgZhN92Rg9vKEhXZgYCJPu41j2", "ji17lTeYQ3QOaM4675OyVQqte0l1"]
    var followingUsers: [User] = []
    var testPosts: [Post] = []
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFollowing()
        workoutCollectionView.delegate = self
        workoutCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    func fetchFollowing() {
        //print("user following \(userFollowing)")
        DispatchQueue.global().async {
            do {
                let followingRef = self.db.collection("users")
                
                let results = followingRef.whereField("uid", in: self.userFollowing)
                results.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        
                        for document in querySnapshot!.documents {
                            var userInfo: User?
                            try? userInfo = document.data(as:User.self)
                            
                            self.followingUsers.append(userInfo ?? User(experience: "err", following: ["err"], height: 0, name: "err", profile_pic: "err", uid: "err", username: "err", weight: 0, email: "err"))
                        }
                    }
                    //updating table
                    DispatchQueue.main.async {
                        for user in self.followingUsers {
                            self.fetchPosts(user: user)
                        }
                    }
                }
            }
        }
    }
    
    func fetchPosts(user:User) {
        //print("list of users u follow \(user.username)")
        DispatchQueue.global().async {
            do {
                let postsRef = self.db.collection("posts")
                
                let results = postsRef.whereField("userId", isEqualTo: user.uid)
                results.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                           // print(document.data().map(String.init(describing:)) ?? "nil")
                            var postInfo: Post?
                            try? postInfo = document.data(as:Post.self)
                            print(postInfo)
                            self.testPosts.append(postInfo ?? Post(exercises: [], likes: 0, title: "err", userId: "err"))
                        }
                    }
                    //updating table
                    DispatchQueue.main.async {
                        if self.testPosts.count == 0 {
                            let alert = UIAlertController(title: "Error", message: "No Results Found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        self.workoutCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = workoutCollectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! HomePageCollectionViewCell
        if let imageURL = testPosts[indexPath.row].picturePath{
            let ref = Storage.storage().reference(forURL: imageURL)
            ref.downloadURL {(url, error) in
                if error != nil {
                    print("uh oh")
                }
                else {
                    let data = try? Data(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    cell.imageView.image = image
                }
            }
        }
        else {
            cell.imageView.image = UIImage()
        }
        cell.titleLabel.text = testPosts[indexPath.row].title
        cell.numLikesLabel.text = "0"
        return cell
    }

}
