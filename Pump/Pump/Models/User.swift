//
//  User.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/1/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
struct User: Codable {
    var experience: String?
    var following: [String]?
    var height: Double?
    var name: String?
    var profile_pic: String
    var uid: String
    var username: String
    var weight: Double?
    var email: String
    
}
