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

class DetailedPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()

    var post: Post?
    var postId: String!
    
    var numExercises = 0
    let numExerciseComponents = 4 //Exercise struct has 4 fields
    let extraComponents = 1 //includes title and numlikes in tableview
    var fontSize:CGFloat = 14
    
    var uniqueSegueIdentifier:String!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchPost()
        
        if uniqueSegueIdentifier == "No Like Button" {
            print("No like button")
            likeButton = UIBarButtonItem(title: "", style:         UIBarButtonItem.Style.plain, target: nil, action: nil)

        } else {
            print("LIKE BUTTON EXISTS")
        }
    }
    
    
    
    func fetchPost(){
        DispatchQueue.global().async {
            do{
                guard let postId = self.postId else {return}
                let postRef = self.db.collection("posts").document(postId)
                postRef.getDocument() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        //print (try? querySnapshot?.data(as:Post.self))
                        try? self.post = querySnapshot?.data(as:Post.self)
                        //updating table
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            if let posts = self.post {
//                                print(posts)
//                                print(posts.exercises.count)
                                self.numExercises = posts.exercises.count
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        likePost()
    }
    
    func likePost() {
        guard let p = post else {
            print("like failed")
            return
        }
        let noti = Notification(postId: postId, postTitle: p.title, receiverId: p.userId, senderId: userID)
        let notiRef = try? db.collection("notifications").addDocument(from: noti)
        self.db.collection("posts").document(postId).setData([ "likes": (p.likes+1)], merge: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numExercises * numExerciseComponents + extraComponents
    }
    
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
                cell.label.text = "Exercise \(index)"
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

