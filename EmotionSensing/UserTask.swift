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

class UserTask {
    var title = ""
    var subtitle = ""
    var summary = ""
    var identifier: String!
    var fireHous: [Int]?
    var notificationDelegate: UNUserNotificationCenterDelegate!
    
    init(title: String, subtitle: String, summary: String, identifier: String, fireHours: [Int], notificationDelegate: UNUserNotificationCenterDelegate) {
        self.title = title
        self.subtitle = subtitle
        self.summary = summary
        self.identifier = identifier
        self.fireHous = fireHours
        self.notificationDelegate = notificationDelegate
    }
}
