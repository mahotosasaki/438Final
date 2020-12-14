//
//  DetailedPostViewController.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/10/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//



import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

// View Controller for displaying detailed workout view
class DetailedPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    var post: Post?
    var postId: String!
    
    var numExercises = 0
    let numExerciseComponents = 4 //Exercise struct has 4 fields
    let extraComponents = 1 //includes title and numlikes in tableview
    var fontSize:CGFloat = 14
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchPost()
    }
    
    // Check if user has liked post already
    func checkLike() {
        db.collection("notifications").whereField("postId", isEqualTo: postId ?? "").whereField("senderId", isEqualTo: userID).getDocuments { (querySnapshot, err) in
            if let err = err {
                print(err)
                self.likeButton.titleLabel?.text = "Like"
                self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            else {
                if querySnapshot!.documents.count == 0 {
                    self.likeButton.titleLabel?.text = "Like"
                    self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                else {
                    self.likeButton.titleLabel?.text = "Liked"
                    self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                
            }
        }
    }
    
    // Gets specific post information for given post
    func fetchPost(){
        DispatchQueue.global().async {
            do{
                guard let postId = self.postId else {return}
                let postRef = self.db.collection("posts").document(postId)
                postRef.getDocument() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        try? self.post = querySnapshot?.data(as:Post.self)
                        //updating table
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            if let posts = self.post {
                                self.navigationItem.title = posts.username
                                self.numExercises = posts.exercises.count
                                self.tableView.reloadData()
                                self.checkLike()
                                self.fetchImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Gets image associated with post
    func fetchImage() {
        if let imageURL = post?.picturePath {
            if imageURL == "" {
                let rect = imageView.bounds
                UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.bounds.width, height: imageView.bounds.height), true, 1.0)
                UIColor.gray.set()
                UIRectFill(rect)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.imageView.image = image
            }
            else {
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
        else {
            let rect = imageView.bounds
            UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.bounds.width, height: imageView.bounds.height), true, 1.0)
            UIColor.gray.set()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageView.image = image
        }
    }
    
    // Triggers when like button pressed
    @IBAction func likeButtonPressed(_ sender: Any) {
        db.collection("notifications").whereField("postId", isEqualTo: postId ?? "").whereField("senderId", isEqualTo: userID).getDocuments { (querySnapshot, err) in
            if let err = err {
                print(err)
                self.likePost()
            }
            else {
                if querySnapshot!.documents.count == 0 {
                    self.likePost()
                }
                else {
                    let notiID = querySnapshot!.documents[0].documentID
                    self.dislikePost(notiID)
                }
                
            }
        }
    }
    
    // Updates post likes in database, likes post
    func likePost() {
        guard let p = post else {
            print("like failed")
            return
        }
        let noti = Notification(postId: postId, postTitle: p.title, receiverId: p.userId, senderId: userID)
        let _ = try? db.collection("notifications").addDocument(from: noti)
        self.db.collection("posts").document(postId).setData([ "likes": (p.likes+1)], merge: true)
        self.likeButton.titleLabel?.text = "Liked"
        self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        
    }
    
    // Updates post lieks in database, unlikes post
    func dislikePost(_ notificationID: String) {
        guard let p = post else {
            print("like failed")
            return
        }
        self.likeButton.titleLabel?.text = "Like"
        self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        self.db.collection("notifications").document(notificationID).delete()
        self.db.collection("posts").document(postId).setData([ "likes": (p.likes-1)], merge: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numExercises * numExerciseComponents + extraComponents
    }
    
    // Create cells for workout information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         0->title
         1->Exercise #
         2->Exercise title
         3->SETS
         4->REPS
         
         2->0
         3->0
         4->0
         5->1
         
         x/5
         */
        
        let index = indexPath.section / 5
        if indexPath.section == 0 {
            let cell:LabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as! LabelTableViewCell
            cell.label.text = self.post?.title
            return cell
        } else {
            if indexPath.section % 4 == 0 {
                let cell:LabelCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! LabelCellTableViewCell
                cell.label.text = "Reps"
                cell.rightLabel.text = post?.exercises[index]["reps"]
                return cell
            } else if indexPath.section % 4 == 1 {
                let cell:LabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as! LabelTableViewCell
                cell.label.text = "Exercise \(index + 1)"
                return cell
            } else if indexPath.section % 4 == 2 {
                let cell:LabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as! LabelTableViewCell
                guard let exerciseTitle = post?.exercises[index]["exercise"] else {
                    cell.label.text = "exercise title"
                    return cell
                }
                cell.label.text = "\(exerciseTitle)"
                return cell
            } else {
                let cell:LabelCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! LabelCellTableViewCell
                cell.label.text = "Sets"
                cell.rightLabel.text = post?.exercises[index]["sets"]
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || (section % numExerciseComponents == 0) {
            return 40
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

