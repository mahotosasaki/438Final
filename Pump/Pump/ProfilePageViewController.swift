//
//  ProfilePageViewController.swift
//  Pump
//
//  Created by Akash Kaul on 11/25/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreData

class ProfilePageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var userPosts = [Post]()
    //we need to figure out how we want to keep track of the userlogged in. I have a hardcoded value for now
    var currUser = "tester"
    let db = Firestore.firestore()
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // https://stackoverflow.com/questions/27880607/how-to-assign-an-action-for-uiimageview-object-in-swift
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        profileImage.layer.borderWidth=1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
        editButton.layer.cornerRadius = 10
        editButton.backgroundColor = UIColor.systemTeal
        editButton.setTitleColor(.white, for: .normal)
        
        picker.delegate = self
        picker.allowsEditing = true
        // Do any additional setup after loading the view.
        
        
        //creating a user Struct as an example
//        var userStruct: User?
//        let userRef = db.collection("users")
//        let call = userRef.whereField("username", isEqualTo: currUser)
//
//        call.getDocuments() { (querySnapshot, err) in
//        if let err = err {
//            print("No results: \(err)")
//
//        } else {
//
//                for document in querySnapshot!.documents {
//                    //sets our userstruct variable to what the document recieved from our call
//                    try? userStruct = document.data(as: User.self)
//                    //sending our userstruct to generatepagedetails function so it can alter the actually page with user info
//                    self.generatePageDetails(userDetails: userStruct!)
//                }
//
//            }
//        }
        var array = [NSManagedObject]()
        array = CoreDataFunctions.getData()
        if array.count > 0{
            for i in 0..<array.count {
                if(array[i].value(forKey: "uid") as? String ?? "uid" == userID){
                    if let base64image = array[i].value(forKey: "profile_pic") as? String {
                        let data = Data(base64Encoded: base64image, options: .init(rawValue: 0))!
                        self.profileImage.image = UIImage(data: data)
                    }
                    self.profileName.text = array[i].value(forKey: "name") as? String ?? "name"
                }
                
            }
//            let user = array.last
//            if let base64image = user?.value(forKey: "profile_pic") as? String {
//                let data = Data(base64Encoded: base64image, options: .init(rawValue: 0))!
//                self.profileImage.image = UIImage(data: data)
//            }
//            self.profileName.text = user?.value(forKey: "name") as? String ?? "name"
        }
    }
    // https://stackoverflow.com/questions/41717115/how-to-make-uiimagepickercontroller-for-camera-and-photo-library-at-the-same-tim
    @objc func imageTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image", message: "Choose an image from your camera roll or take a picture", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { _ in
            self.openLibrary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Camera Unavailable", message: "The camera cannot be accessed on this device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {return}
        profileImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    //changes profile page info with struct data
    //need to finish filling in once we figure out how to upload and recieve profile pictures
    func generatePageDetails(userDetails: User) {
        profileName.text = userDetails.name
        
        /*if we were to also show all the posts of the user on the profile page. not finished 
        var user = "someguysid"
        //need to get that persons id maybe
        let postRefs = db.collection("posts")
        userPosts = postRefs.whereField("userid", isEqualTo: currUser)
         */
    }

    @IBAction func editProfile(_ sender: UIButton) {
        var exercises = [[String: String]]()
        exercises.append(["exercises": "bench", "reps": "5", "sets": "5"])
        exercises.append(["exercises": "squuats", "reps": "10", "sets": "2"])
        //added id
        let post = Post(id: "randomidtest", exercises: exercises, likes: 0, title: "TestPost", userId: "currentUser")
        let detailed = DetailedWorkoutController(post: post)
        navigationController?.pushViewController(detailed, animated: true)
    }
}
