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
    var postTitle: String
    var receiverId: String
    var senderId: String
}
