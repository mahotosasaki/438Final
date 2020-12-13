//
//  EditProfileViewController.swift
//  Pump
//
//  Created by Akash Kaul on 12/12/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//


import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class EditProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    var userStruc: User?
    let db = Firestore.firestore()
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var displayNameField: UITextField!
    
    @IBOutlet weak var heightField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    
    @IBOutlet weak var experienceField: UITextField!
    let pickerOptions = ["Beginner", "Intermediate", "Advanced"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        experienceField.text = pickerOptions[row]
    }
    
    @objc func selectDone() {
        if (!pickerOptions.contains(experienceField.text ?? "")) {
            experienceField.text = pickerOptions[0]
        }
        experienceField.resignFirstResponder()
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let expPicker = UIPickerView()
        expPicker.delegate = self
        expPicker.dataSource = self
        expPicker.backgroundColor = UIColor.systemGray4
        experienceField.inputView = expPicker
        experienceField.tintColor = UIColor.clear
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(selectDone))
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        experienceField.inputAccessoryView = toolbar
        
        emailField.text = userStruc?.email
        nameField.text = userStruc?.name
        displayNameField.text = userStruc?.username
        experienceField.text = userStruc?.experience
        if let height = userStruc?.height {
            heightField.text = "\(height)" as String
        } else {
            print("Missing height.")
        }
        if let weight = userStruc?.weight {
            weightField.text = "\(weight)" as String
        } else {
            print("Missing weight.")
        }
        
        
        
        //experienceField
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        
        let height = Double(heightField.text ?? "0.0")
        let weight = Double(weightField.text ?? "0.0")
        
        if checkFields(){
            if validateSignUp() {
                errorLabel.text = nil
                self.db.collection("users").document(userID).setData(["email":  emailField.text ?? "", "name":nameField.text ?? "", "username": displayNameField.text ?? "", "height": height  ?? 0, "weight": weight ?? 0, "experience": self.experienceField.text ?? "beginner"], merge: true)
                Auth.auth().currentUser?.updateEmail(to: emailField.text ?? "error email") { (error) in
                    // ...
                }
                Auth.auth().currentUser?.updatePassword(to: passwordField.text ?? "error password") { (error) in
                    // ...
                }
            }
            else {
                if !checkEmail(emailField.text ?? "") && !checkPassword(passwordField.text ?? ""){
                    errorLabel.text = "Please enter a valid email and password"
                }
                else if !checkEmail(emailField.text ?? "") {
                    errorLabel.text = "Please enter a valid email"
                }
                else if !checkPassword(passwordField.text ?? ""){
                    errorLabel.text = "Please enter a valid password"
                } else {
                    errorLabel.text = "Pleae enter a valid username"
                }
            }
        }
        else {
            errorLabel.text = "One or more required fields is blank"
        }
        
        
    }
    
    func validateSignUp() -> Bool{
        return checkEmail(emailField.text ?? "") && checkPassword(passwordField.text ?? "") && checkDisplayName(displayNameField.text ?? "")
    }
    
    func checkFields() -> Bool {
        return (nameField.text?.count ?? 0 > 0) && (passwordField.text?.count ?? 0 > 0) && (emailField.text?.count ?? 0 > 0) && (displayNameField.text?.count ?? 0 > 0)
    }
    
    func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // PASSWORD REGEX
    func checkPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
        
        let passPred = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passPred.evaluate(with: password)
    }
    
    // DISPLAY NAME REGEX AND UNIQUENESS
    func checkDisplayName(_ displayName: String) -> Bool{
        
        let displayNameRegex = "^\\w{7,18}$"
        
        let displayPred = NSPredicate(format:"SELF MATCHES %@", displayNameRegex)
        
        if !displayPred.evaluate(with: displayName){
            return false
        }
        
        var flag = true
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("username", isEqualTo: displayNameField.text!).getDocuments { (res, err) in
            if(res?.count != 0 && self.displayNameField.text != self.userStruc?.username){
                flag = false
            }
        }
        
        return flag
    }
    
}
