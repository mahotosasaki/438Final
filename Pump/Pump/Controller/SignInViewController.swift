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

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
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
                        print("wrong password")
                    case .invalidEmail:
                        print("wrong email")
                    default:
                        print("Error: \(error.localizedDescription)")
                    }
                    
                  } else {
                    print("User signs in successfully")
                    let userInfo = Auth.auth().currentUser
                    let email = userInfo?.email
                    print(userInfo)
                  }
                }
        } else {
            print("invalid")
        }
    }

}