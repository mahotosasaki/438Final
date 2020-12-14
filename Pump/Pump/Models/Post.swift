//
//  Post.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/1/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

// Post struct
struct Post: Codable {
    var id: String
    var exercises: [[String:String]]
    var likes: Int
    var title: String
    var userId: String
    var username: String
    var picturePath:String?
}
