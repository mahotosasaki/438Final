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
    var id: String
    var exercises: [[String:String]]
    var likes: Int
    var title: String
    var userId: String
    var username: String
    var picturePath:String?
}

//replace var exercises with 3 arrays: exerciseTitle, exerciseReps, exerciseSets
struct Workout: Codable {
    var userID:String
    var title:String
    var likes:String
    var picturePath:String
    var exercises:[Exercise]
}
struct Exercise:Codable {
    var number:String
    var name:String
    var reps:String
    var sets:String
}
