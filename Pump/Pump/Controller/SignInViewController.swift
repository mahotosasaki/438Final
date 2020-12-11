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

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
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
                    for i in 0..<array.count {
                        if(array[i].value(forKey: "email") as? String ?? "email" == email){
                            print(array[i].value(forKey: "uid") as? String ?? "uid")
                            //setting user id global variable from core data
                            userID = array[i].value(forKey: "uid") as? String ?? "uid"
                            //following global variable for id's of people we follow
                            //userFollowing = array[i].value(forKey: "following") as? [String] ?? []
                        }
                        
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

}
