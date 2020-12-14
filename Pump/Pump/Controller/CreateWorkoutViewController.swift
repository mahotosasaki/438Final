//
//  CreateWorkoutViewController.swift
//  Pump
//
//  Created by Mahoto Sasaki on 11/16/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class CreateWorkoutViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let db = Firestore.firestore()
    let ref = Storage.storage().reference()
    
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var picturePath = ""
    
    @IBOutlet weak var tableView: UITableView!
    var numTableViewSections = 6
    let numExerciseComponents = 4
    var fontSize:CGFloat = 14
    var tableTextField:[String] = []
    var tableData:[String] = ["", "", "", "1" ,"1"]
    
    var pickerView = UIPickerView()
    var pickerViewDoneButton = UIButton()
    var pickerViewData = [Int]()
    var pickerViewVisible = true
    var chosenCellPickerViewSection = 0
    var pickerViewHistory = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        for i in 1...50 {
            pickerViewData.append(i)
        }
        
        let x = tableView.frame.origin.x
        let y = tableView.frame.origin.y
        let height = tableView.frame.height
        let width = tableView.frame.width
        
        pickerView = UIPickerView(frame: CGRect(x: x, y: y + height / 2 + 40, width: width, height: height / 2 - 40))
        pickerView.backgroundColor = UIColor.systemGray
        view.addSubview(pickerView)

        pickerViewDoneButton = UIButton(frame: CGRect(x: x, y: y + height / 2, width: width, height: 40))
        pickerViewDoneButton.setTitle("Done", for: .normal)
        pickerViewDoneButton.backgroundColor = UIColor.green
        pickerViewDoneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        view.addSubview(pickerViewDoneButton)
        
        pickerView.delegate = self
        pickerView.dataSource = self
                
        hidePickerView()
        //tap gesture obtained from https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        //image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.layer.borderWidth=1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hidePickerView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableData[textField.tag] = textField.text ?? ""
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton){
        hidePickerView()
        
        //adding a post with the struct
        //the variable j is used for indexing specific values from our tableData array
        var j = 2
        var exerciseDict = [[String:String]]()
        while j < tableData.count {
            var ex = [String:String]()
            ex["exercise"] = tableData[j]
            j = j+1
            ex["reps"] = tableData[j]
            j = j+1
            ex["sets"] = tableData[j]
            j = j+2
            exerciseDict.append(ex)
        }
        
        let uniqueId = db.collection("post").document().documentID;
        var myPost = Post(id: uniqueId, exercises: exerciseDict, likes: 0, title: tableData[0], userId: userID, username: USERNAME, picturePath: "")
        //adding our post struct to database
        if let image = self.imageView.image {
            let fileRef = ref.child("postImages\(userID + myPost.title).jpg")
            fileRef.putData(image.pngData()!, metadata: nil) {(metadata, error) in
                if error != nil {
                    print("error saving post image")
                }
                else {
                    fileRef.downloadURL { (url, error) in
                        if error != nil {
                            print("error grabing image")
                        }
                        else {
                            guard let downloadURL = url else {return}
                            myPost.picturePath = downloadURL.absoluteString
                            self.addPost(myPost)
                        }
                    }
                }
            }
        }
        else {
            addPost(myPost)
        }
        
    }
    
    func addPost(_ post: Post) {
        do {
            let _ = try db.collection("posts").document(post.id).setData(from: post)
            numTableViewSections = 6
            tableData = ["", "", "", "1" ,"1"]
            imageView.image = UIImage()
            
            tableView.reloadData()
            let alert = UIAlertController(title: "Success", message: "Post created successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        catch {
            print(error)
            let alert = UIAlertController(title: "Error", message: "The post could not be created. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
}

extension CreateWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numTableViewSections
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LabelCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LabelCellTableViewCell
        cell.label?.font = UIFont.systemFont(ofSize: fontSize)
        cell.rightLabel.font  = UIFont.systemFont(ofSize: fontSize)
        
        if indexPath.section % numExerciseComponents == 0 {
            if indexPath.section == 0 {
                let cell:TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! TextFieldTableViewCell
                cell.workoutTitleTextField.delegate = self
                cell.workoutTitleTextField.tag = indexPath.section
                cell.workoutTitleTextField.text = tableData[indexPath.section]
                return cell
            }
            cell.label?.text = "Reps"
            cell.rightLabel.text = tableData[indexPath.section]
            //tableData[indexPath.section] = cell.label.text ?? ""
            
        } else if indexPath.section % numExerciseComponents == 1 {
            if indexPath.section == numTableViewSections - 1 {
                cell.label?.text = "Add Exercise"
                cell.rightLabel.text = ""
                return cell
            }
            
            let exerciseCell:DeleteWorkoutTableViewCell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell") as! DeleteWorkoutTableViewCell
            exerciseCell.exerciseLabel.text = "Exercise \(indexPath.section / numExerciseComponents + 1)"
            exerciseCell.deleteButton.tag = indexPath.section
            exerciseCell.deleteButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            if indexPath.section == 1 {
                exerciseCell.deleteButton.isHidden = true
            } else {
                exerciseCell.deleteButton.isHidden = false
            }
            
            tableData[indexPath.section] = "\(indexPath.section / numExerciseComponents)"
            return exerciseCell
        } else if indexPath.section % numExerciseComponents == 2 {
            let cell:TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! TextFieldTableViewCell
            cell.workoutTitleTextField.placeholder = "Exercise Title"
            cell.workoutTitleTextField.delegate = self
            cell.workoutTitleTextField.tag = indexPath.section
            cell.workoutTitleTextField.text = tableData[indexPath.section]
            return cell
        } else if indexPath.section % numExerciseComponents == 3 {
            cell.label?.text = "Sets"
            cell.rightLabel.text = tableData[indexPath.section]
        }
        return cell
    }
    
    @objc func buttonClicked(sender:UIButton){
        for _ in 1...numExerciseComponents {
            tableData.remove(at: sender.tag)
        }
        
        numTableViewSections -= numExerciseComponents
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hidePickerView()
        if indexPath.section == numTableViewSections - 1 {
            numTableViewSections += numExerciseComponents
            
            for i in 1...numExerciseComponents {
                if i == numExerciseComponents - 1 || i == numExerciseComponents {
                    tableData.append("1")
                } else {
                    tableData.append("")
                }
            }
            tableView.reloadData()
        } else if indexPath.section % numExerciseComponents == 3 {
            showPickerView(section: indexPath.section)
            chosenCellPickerViewSection = indexPath.section
        } else if indexPath.section % numExerciseComponents == 0 && indexPath.section != 0 {
            showPickerView(section: indexPath.section)
            chosenCellPickerViewSection = indexPath.section
        }
    }
    
}

extension CreateWorkoutViewController: UIPickerViewDataSource, UIPickerViewDelegate  {
    @objc func doneButtonPressed(){
        hidePickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerViewData[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let data = pickerViewData[row]
        updatePickerViewHistory(index: chosenCellPickerViewSection, value: data)
        tableData[chosenCellPickerViewSection] = "\(data)"
        tableView.reloadData()
    }
        
    func hidePickerView(){
        pickerView.isHidden = true
        pickerViewDoneButton.isHidden = true
    }
    
    func showPickerView(section:Int){
        pickerView.isHidden = false
        pickerViewDoneButton.isHidden = false
        
        pickerView.selectRow(getPickerViewHistory(index: section), inComponent: 0, animated: true)
    }
    
    func getPickerViewHistory(index:Int) -> Int{
        var newIndex = index
        if index != 0 {
            if index % numExerciseComponents == 0 {
                newIndex = (newIndex - 2) / 2
            } else if index % numExerciseComponents == 3 {
                newIndex = (newIndex - 3) / 2
            }
            
            if newIndex > pickerViewHistory.count - 1 {
                for _ in pickerViewHistory.count...newIndex {
                    pickerViewHistory.append(1)
                }
            }
        }
        return pickerViewHistory[newIndex] - 1
    }
    
    func updatePickerViewHistory(index:Int, value:Int){
        /*
         0 3
         2 7
         4 11
         6 15
         x * 2 + 3 -> y
         
         1 4
         3 8
         5 12
         7 16
         x * 2 + 2 -> y
         */
        
        var newIndex = index
        if index != 0 {
            if index % numExerciseComponents == 0 {
                newIndex = (newIndex - 2) / 2
            } else if index % numExerciseComponents == 3 {
                newIndex = (newIndex - 3) / 2
            }
            pickerViewHistory[newIndex] = value
        }
    }
}


