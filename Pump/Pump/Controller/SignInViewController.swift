//
//  SignInViewController.swift
//  Pump
//
//  Created by Mark Sigel on 12/7/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData
import FirebaseStorage

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()
    
    var user: User?
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.layer.cornerRadius = 10
        signInButton.backgroundColor = UIColor.systemTeal
        signInButton.setTitleColor(.white, for: .normal)
    }
    
    func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validateInput() -> Bool{
        return passwordField.text! != "" && checkEmail(emailField.text!)
    }
    
    @IBAction func signIn(_ sender: Any) {
        if(validateInput()){
            //do auth
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { authResult, error in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                        case .operationNotAllowed:
                            print("not allowed")
                        case .wrongPassword:
                            self.errorLabel.text = "Invalid password"
                        case .invalidEmail:
                            self.errorLabel.text = "Invalid email"
                        case .userNotFound:
                             self.errorLabel.text = "User does not exist"
                        default:
                            print("Error: \(error.localizedDescription)")
                    }
                    
                  } else {
                    print("User signs in successfully")
//                    let userInfo = Auth.auth().currentUser
                    let email = Auth.auth().currentUser?.email
                    var array = [NSManagedObject]()
                    array = CoreDataFunctions.getData()
                    print(array.count)
                    var foundUser = false
                    for i in 0..<array.count {
                        if(array[i].value(forKey: "email") as? String ?? "email" == email){
                            print(array[i].value(forKey: "uid") as? String ?? "uid")
                            //setting user id global variable from core data
                            userID = array[i].value(forKey: "uid") as? String ?? "uid"
                            USERNAME = array[i].value(forKey: "displayName") as? String ?? "username"
                            foundUser = true
                            //following global variable for id's of people we follow
                            //userFollowing = array[i].value(forKey: "following") as? [String] ?? []
                        }
                        
                    }
                    print("check 1")
                    if !foundUser {
                        print("check 2")
                        self.fetchUser(authResult!.user.uid)
                    }
                    self.performSegue(withIdentifier: "showTabBar", sender: self)
                  }
                }
        } else {
            if !checkEmail(emailField.text!){
                errorLabel.text = "Enter a valid email address"
            } else {
                errorLabel.text = "Enter a valid password"
            }
        }
    }
    
    func fetchUser(_ userID: String) {
        DispatchQueue.global().async {
            do{
                print("check 3")
                let postRef = self.db.collection("users").document(userID)
                postRef.getDocument() { (querySnapshot, err) in
                    if let err = err {
                        print("No results: \(err)")
                    } else {
                        //print (try? querySnapshot?.data(as:Post.self))
                        print("check 4")
                        try? self.user = querySnapshot?.data(as:User.self)
                        //updating table
                        DispatchQueue.main.async {
                            if let user = self.user {
                                print("check 5")
                                self.fetchImage(user.profile_pic, user)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchImage(_ imageURL: String, _ user: User) {
        if imageURL == "" {
            print("image url blank")
            CoreDataFunctions.save(user)
        }
        else {
            print("image url exists")
            let ref = Storage.storage().reference(forURL: imageURL)

            ref.downloadURL {(url, error) in
                if error != nil {
                    print("uh oh")
                }
                else {
                    print("got image url successfully")
                    let data = try? Data(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    let user = User(experience: user.experience ?? "Beginner", following: user.following ?? [user.uid], height: user.height ?? 0.0, name: user.name ?? "", profile_pic: image?.pngData()?.base64EncodedString() ?? "", uid: user.uid, username: user.username, weight: user.weight ?? 0.0, email: user.email)
                    print("saving user")
                    CoreDataFunctions.save(user)
                }
            }
        }
    }

}
