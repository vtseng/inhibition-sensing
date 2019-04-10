//
//  UserTask.swift
//  EmotionSensing
//
//  Created by Vincent on 4/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class UserTask: NSObject{
    var title = ""
    var message = ""
    var identifier: String!
    var fireHous: [Int]?
    var expirationThreshold: Int! // The task will expire after the given threshold (minutes)
    var notificationDelegate: UNUserNotificationCenterDelegate!
    
    init(title: String, message: String, identifier: String, fireHours: [Int], expirationThreshold: Int, notificationDelegate: UNUserNotificationCenterDelegate) {
        self.title = title
        self.message = message
        self.identifier = identifier
        self.fireHous = fireHours
        self.expirationThreshold = expirationThreshold
        self.notificationDelegate = notificationDelegate
    }
}
