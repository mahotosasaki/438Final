//
//  SignUpViewController.swift
//  Pump
//
//  Created by Akash Kaul on 11/25/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

//https://stackoverflow.com/questions/31728680/how-to-make-an-uipickerview-with-a-done-button

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var experienceField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var heightField: UITextField!
    
    @IBOutlet weak var displayNameField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    let pickerOptions = ["Beginner", "Intermediate", "Advanced"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImage.layer.borderWidth=1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
        let expPicker = UIPickerView()
        expPicker.delegate = self
        expPicker.dataSource = self
        expPicker.backgroundColor = UIColor.systemGray4
        experienceField.inputView = expPicker
        experienceField.tintColor = UIColor.clear
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.backgroundColor = UIColor.systemTeal
        signUpButton.setTitleColor(.white, for: .normal)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(selectDone))

        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        experienceField.inputAccessoryView = toolbar
        // Do any additional setup after loading the view.
    }
    
    @objc func selectDone() {
        if (!pickerOptions.contains(experienceField.text ?? "")) {
            experienceField.text = pickerOptions[0]
        }
        experienceField.resignFirstResponder()
    }
    
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
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Camera Unavailable", message: "The camera cannot be accessed on this device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {return}
        profileImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
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
    
    func signUpUser(){
        // add users to user auth
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { res, err  in
            if err != nil{
                print("error creating user")
                print(err!)
            } else {
                // add user to users collection
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["uid": res!.user.uid, "username": self.displayNameField.text!, "height": self.heightField.text!, "weight": self.weightField.text!, "experience": self.experienceField.text!]) {(err) in
                    
                    if err != nil{
                        print("error adding to users collection")
                        print(err!)
                    }
                }
            }
        
        }
    }
    
    func validateSignUp() -> Bool{
        return checkEmail(emailField.text!) && checkPassword(passwordField.text!)
    }
    
    func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func checkPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"

        let passPred = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passPred.evaluate(with: password)
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        if validateSignUp(){
            signUpUser()
        } else {
            // UI warnings here
        }
    }
    
}
