//
//  UserTaskScheduler.swift
//  EmotionSensing
//
//  Created by Vincent on 4/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

let STOP_SIGNAL_TASK_IDENTIFIER = "StopSignalTask"

class UserTaskScheduler {
    
    static let shared = UserTaskScheduler()
    
    
    var tasksToBeScheduled: [UserTask]! // Tasks awaiting to be schedules
    var pendingTasks: [UserTask]! // Tasks fired but not yet completed by user
    
    init() {
        tasksToBeScheduled = []
        pendingTasks = []
    }
    
    
    func scheduleTask(_ task: UserTask) {
        tasksToBeScheduled.append(task)
    }
    
    
    func  addPendingTask(_ task: UserTask) {
        pendingTasks.append(task)
    }
    
    
    func refrshNotificationSchedules() {
        for task in tasksToBeScheduled {
            if let hours = task.fireHous {
            
                for hour in hours {
                    let content = UNMutableNotificationContent()
                    content.title = task.title
                    content.subtitle = task.subtitle
                    content.body = task.summary
//                    content.userInfo = [KEY_TASK_INTRODUCTION_VIEW_CONTROLLER: UIViewController.self]
                    content.categoryIdentifier = task.identifier
                    content.badge = 1
                    
                    var dateComponents = DateComponents()
                    dateComponents.hour = hour
                    dateComponents.minute = 30
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: task.identifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    UNUserNotificationCenter.current().delegate = task.notificationDelegate
                    
                }
                
            }
        }
    }
    
    
    func removeNotificationSchedules() {
    }
    
    
    
}
