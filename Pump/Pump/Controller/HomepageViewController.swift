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
class HomepageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var workoutCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
    
    //this is hardcoded, needs to be the actual following list which probably needs to be pulled from coredata
    var userFollowing: [String] = []
    var followingUsers: [User] = []
    var posts: [Post] = []
    //
    
    override func viewDidLoad() {
        //setup()
        workoutCollectionView.delegate = self
        workoutCollectionView.dataSource = self
        workoutCollectionView.register(PostCell.self, forCellWithReuseIdentifier: "postCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup(){
        userFollowing = []
        followingUsers = []
        posts = []
        getFollowingIds()
    }
    
    func getFollowingIds(){
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
                            
                            //print(userInfo)
                            
                            self.userFollowing = userInfo?.following ?? User(experience: "err", following: [], height: 0, name: "err", profile_pic: "err", uid: "err", username: "err", weight: 0, email: "err").following!
                        }
                    }
                    DispatchQueue.main.async {
                        print("GET USER IDS \(self.userFollowing.count)")
                        if(!self.userFollowing.isEmpty){
                            self.fetchFollowingUsersObj()
                        }
                    }
                }
            }
        }
        
    }
    
    func fetchFollowingUsersObj() {
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
                        print("FOOLOWING USERS \(self.followingUsers.count)")
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
                            //print(postInfo)
                            self.posts.append(postInfo ?? Post(id: "err", exercises: [], likes:0, title: "err", userId: "err", username: " ", picturePath: ""))
                        }
                    }
                    //updating table
                    DispatchQueue.main.async {
                        print("POSTS COUNT \(self.posts.count)")
                        
                        //creating an alert is not the greatest way of checking because one user can have 0 posts while the next can have >0 posts and the alert would trigger anyways
//                        if self.posts.count == 0 {
//                            let alert = UIAlertController(title: "Error", message: "No Results Found", preferredStyle: .alert)
//                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
//
//                        }
                        self.workoutCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.workoutCollectionView.frame.size.width*0.8, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = workoutCollectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        if let imageURL = posts[indexPath.row].picturePath {
            if imageURL == "" {
                let rect = CGRect(x: 0,y: 0,width: 120,height: 200)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 120, height: 200), true, 1.0)
                UIColor.gray.set()
                UIRectFill(rect)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                cell.imageView.image = image
            } else {
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
        }
        else {
            let rect = CGRect(x: 0,y: 0,width: 120,height: 200)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 120, height: 200), true, 1.0)
            UIColor.gray.set()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            cell.imageView.image = image
        }
        cell.titleLabel.text = posts[indexPath.row].title
        cell.likesLabel.text = "\(posts[indexPath.row].likes) likes"
        cell.usernameLabel.text = posts[indexPath.row].username
        return cell
    }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//            let detailVC = DetailedPostViewController()
//            detailVC.post = posts[indexPath.row]
//            detailVC.postId = posts[indexPath.row].id
//            navigationController?.pushViewController(detailVC, animated: true)
             self.performSegue(withIdentifier: "fromHomeToPost", sender: posts[indexPath.row].id)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if (segue.identifier == "toDetailedWorkout") {
    //
    //            let detailedPostView = segue.destination as? DetailedWorkoutController
    //            detailedPostView?.postId = sender as! String
    //        }
            if(segue.identifier == "fromHomeToPost") {
                let detailedPostView = segue.destination as? DetailedPostViewController
                detailedPostView?.postId = sender as? String
                detailedPostView?.uniqueSegueIdentifier = "Like Button"
            }
        }
    
}
