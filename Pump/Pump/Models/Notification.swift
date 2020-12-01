//
//  Notification.swift
//  Pump
//
//  Created by Reshad Hamauon on 12/1/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
struct Notification: Codable {
    var postId: String
    var receiverId: String
    //on firestore senderID is a reference so having it as a string here is a problem for decoding
    var senderId: String
}
