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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    
    var userProfile: User!
    var profilePosts: [Post] = []
    var userFollowing: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameLabel.text = userProfile.username
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: "postCell")
                
        followButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profilePosts = []
        userFollowing = []
        setup()
        heightLabel.text = "\(userProfile.height ?? 0) ft"
        weightLabel.text = "\(userProfile.weight ?? 0) lbs"
        experienceLabel.text = "\(userProfile.experience ?? "")"
    }
    
    func setup(){
        fetchUserPosts()
        getProfileImage()
        getFollowingIds()
    }
    
    func getProfileImage(){
        let data = db.collection("users")
        let results = data.whereField("uid", isEqualTo: self.userProfile?.uid ?? "")
        
        results.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("No results: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var userInfo: User?
                    try? userInfo = document.data(as:User.self)
                    if let imageURL = userInfo?.profile_pic {
                        if imageURL == "" {
                            let rect = CGRect(x: 0,y: 0,width: 120,height: 200)
                            UIGraphicsBeginImageContextWithOptions(CGSize(width: 120, height: 200), true, 1.0)
                            UIColor.gray.set()
                            UIRectFill(rect)
                            let image = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            self.imageView.image = image
                        } else {
                            let ref = Storage.storage().reference(forURL: imageURL)
                            
                            ref.downloadURL {(url, error) in
                                if error != nil {
                                    print("uh oh")
                                }
                                else {
                                    let data = try? Data(contentsOf: url!)
                                    let image = UIImage(data: data! as Data)
                                    self.imageView.image = image
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
            }
        }
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
                                                        
                            self.userFollowing = userInfo?.following ?? User(experience: "err", following: [], height: 0, name: "err", profile_pic: "err", uid: "err", username: "err", weight: 0, email: "err").following!
                        }
                    }
                    DispatchQueue.main.async {
                        if self.userFollowing.contains(self.userProfile.uid) {
                            self.followButton.layer.backgroundColor = UIColor.systemGray.cgColor
                            self.followButton.titleLabel?.text = "Following"
                        }
                    }
                }
            }
        }
        
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
                        if self.userFollowing.contains(self.userProfile.uid) {
                            self.db.collection("users").document(userID).updateData(["following": FieldValue.arrayRemove([self.userProfile.uid])])
                            self.followButton.layer.backgroundColor = UIColor.systemTeal.cgColor
                            self.followButton.titleLabel?.text = "Follow"
                        }
                        else {
                            self.userFollowing.append(self.userProfile.uid)
                            self.db.collection("users").document(userID).setData([ "following": self.userFollowing], merge: true)
                            self.followButton.layer.backgroundColor = UIColor.systemGray.cgColor
                            self.followButton.titleLabel?.text = "Following"
                        }
                    }
                }
            }
        }
    }
    
    func fetchUserPosts() {
        DispatchQueue.global().async {
            do {
                let postsRef = self.db.collection("posts")
                
                let results = postsRef.whereField("userId", isEqualTo: self.userProfile?.uid ?? "")
                
                results.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            var postInfo: Post?
                            try? postInfo = document.data(as:Post.self)
                            self.profilePosts.append(postInfo ?? Post(id: "", exercises: [], likes: 0, title: "err", userId: "err", username: "err", picturePath: "" ))
                        }
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return profilePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width*0.8, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        if let imageURL = profilePosts[indexPath.row].picturePath {
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
        cell.titleLabel.text = profilePosts[indexPath.row].title
        cell.likesLabel.text = "\(profilePosts[indexPath.row].likes) likes"
        cell.usernameLabel.text = profilePosts[indexPath.row].username
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "searchToDetailedVC", sender: profilePosts[indexPath.row].id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "searchToDetailedVC") {
            let detailedPostView = segue.destination as? DetailedPostViewController
            detailedPostView?.postId = sender as? String
        }
    }
}

