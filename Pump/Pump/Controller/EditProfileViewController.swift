//
//  EditProfileViewController.swift
//  Pump
//
//  Created by Akash Kaul on 12/12/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var displayNameField: UITextField!
    
    @IBOutlet weak var heightField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var experienceField: UITextField!
    
    
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveData(_ sender: Any) {
        
    }
}
