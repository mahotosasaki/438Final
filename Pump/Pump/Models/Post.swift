//
//  Post.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/1/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
struct Post: Codable {
    var exercises: [[String:String]]
    var likes: Int
    var title: String
    var userId: String
}

//replace var exercises with 3 arrays: exerciseTitle, exerciseReps, exerciseSets
struct Exercise {
    var title: String
    var reps: Int
    var sets: Int
}

