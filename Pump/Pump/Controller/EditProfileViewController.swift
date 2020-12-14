//
//  EditProfileViewController.swift
//  Pump
//
//  Created by Akash Kaul on 12/12/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import CoreData

// View Controller for Edit Profile page
// Similar to sign up page
class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let picker = UIImagePickerController()
    var imageURL = ""
    
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
        emailField.isUserInteractionEnabled = false
        nameField.text = userStruc?.name
        displayNameField.text = userStruc?.username
        experienceField.text = userStruc?.experience
        if let height = userStruc?.height {
            heightField.text = "\(height)" as String
        }
        if let weight = userStruc?.weight {
            weightField.text = "\(weight)" as String
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImage.layer.borderWidth=1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
        picker.delegate = self
        picker.allowsEditing = true
        
        // Get user from core data
        var array = [NSManagedObject]()
        array = CoreDataFunctions.getData()
        if array.count > 0{
            for i in 0..<array.count {
                if(array[i].value(forKey: "uid") as? String ?? "uid" == userID){
                    if let base64image = array[i].value(forKey: "profile_pic") as? String {
                        let data = Data(base64Encoded: base64image, options: .init(rawValue: 0))!
                        self.profileImage.image = UIImage(data: data)
                    }
                }
                
            }
        }
    }
    
    @objc func selectDone() {
        if (!pickerOptions.contains(experienceField.text ?? "")) {
            experienceField.text = pickerOptions[0]
        }
        experienceField.resignFirstResponder()
    }
    
    // Triggered when save button clicked
    @IBAction func saveData(_ sender: Any) {
        let height = Double(heightField.text ?? "0.0")
        let weight = Double(weightField.text ?? "0.0")
        
        if checkFields(){
            if validateSignUp() {
                errorLabel.text = nil
                
                
                self.userStruc?.height = height
                self.userStruc?.weight = weight
                self.userStruc?.email = emailField.text ?? ""
                self.userStruc?.name = nameField.text ?? ""
                self.userStruc?.username = displayNameField.text ?? ""
                self.userStruc?.experience = experienceField.text ?? ""
                self.userStruc?.profile_pic = self.profileImage.image?.pngData()?.base64EncodedString() ?? ""
                if let user = userStruc {
                    CoreDataFunctions.save(user)
                }
                
                if let image = self.profileImage.image {
                    let ref = Storage.storage().reference().child("userImages\(userID).jpg")
                    ref.putData(image.pngData()!, metadata: nil) { (metadata, error) in
                        if error != nil {
                            print("error saving image")
                        }
                        else {
                            ref.downloadURL { (url, error2) in
                                if error2 != nil {
                                    print("error grabbing image url")
                                }
                                else {
                                    guard let downloadURL = url else {return}
                                    self.imageURL = downloadURL.absoluteString
                                    self.sendToFirebase(userID)
                                }
                            }
                        }
                    }
                }
                else {
                    self.sendToFirebase(userID)
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
    
    // VALIDATE EMAIL, PASSWORD, DISPLAY NAME
    func validateSignUp() -> Bool{
        return checkEmail(emailField.text ?? "") && checkPassword(passwordField.text ?? "") && checkDisplayName(displayNameField.text ?? "")
    }
    
    // CHECK FIELDS ARE FILLED
    func checkFields() -> Bool {
        return (nameField.text?.count ?? 0 > 0) && (passwordField.text?.count ?? 0 > 0) && (emailField.text?.count ?? 0 > 0) && (displayNameField.text?.count ?? 0 > 0)
    }
    
    // EMAIL REGEX
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
    
    // Update user in Database
    func sendToFirebase(_ uid:String) {
        let height = Double(self.heightField.text ?? "0.0")
        let weight = Double(self.weightField.text ?? "0.0") ?? 0
        
        let email = self.emailField.text ?? ""
        let name = self.nameField.text ?? ""
        let username = self.displayNameField.text ?? ""
        
        let experience = self.experienceField.text ?? "Beginner"
        
        db.collection("users").document(userID).setData(["email":  email, "name":name, "username": username, "height": height ?? 0, "weight": weight, "experience": experience, "profile_pic": self.imageURL], merge: true) {(err) in
            
            if err != nil{
                let alert = UIAlertController(title: "Error", message: "\(err?.localizedDescription ?? "Unknown error.") Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else {
                let alert = UIAlertController(title: "Saved", message: "Your profile has been updated", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//Picture functionality
extension EditProfileViewController {
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
}

extension EditProfileViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
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
}
