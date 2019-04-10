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

let USER_TASK_NOTIFICATION = "pending_user_task"
let STOP_SIGNAL_TASK_IDENTIFIER = "StopSignalTask"

class UserTaskScheduler {
    
    static let shared = UserTaskScheduler()
    
    
    var tasksToBeScheduled: [UserTask]! // Tasks awaiting to be scheduled
    var scheduledTasks: [UserTask]! // Tasks scheduled but not yet fired
    
    init() {
        tasksToBeScheduled = []
        scheduledTasks = []
    }
    
    
    func scheduleTask(_ task: UserTask) {
        tasksToBeScheduled.append(task)
    }
    
    
    func getPendingTasks() -> [UserTask] {
        var pendingTasks: [UserTask] = []
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        let date = Date()
        let dateFromComponents = calendar.date(from: dateComponents)
        
        for task in scheduledTasks {
            var fireDateComponents = dateComponents
            for hour in task.fireHous! {
                fireDateComponents.timeZone = TimeZone.current
                fireDateComponents.hour = hour
                fireDateComponents.minute = 0

                
                let fireDate = calendar.date(from: fireDateComponents)!
                
                print(Date().addingTimeInterval(TimeInterval(task.expirationThreshold*60)))
                if Date() > fireDate && Date() < fireDate.addingTimeInterval(TimeInterval(task.expirationThreshold*60)) {
                    pendingTasks.append(task)
                }
                
            }
        }
        
        print("pending tasks \(pendingTasks)")
        return pendingTasks
    }
    
    
    func refrshNotificationSchedules() {
        for task in tasksToBeScheduled {
            if let hours = task.fireHous {
            
                for hour in hours {
                    let content = UNMutableNotificationContent()
                    content.title = task.title
                    content.body = task.message
//                    content.userInfo = [KEY_TASK_INTRODUCTION_VIEW_CONTROLLER: UIViewController.self]
                    content.categoryIdentifier = task.identifier
                    content.badge = 1
                    
                    var dateComponents = DateComponents()
                    dateComponents.hour = hour
                    dateComponents.minute = 2
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let notificationIdentifier = createNotificationIdentifier(taskIdentifier: task.identifier, fireHour: hour)
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    UNUserNotificationCenter.current().delegate = task.notificationDelegate
                    
                }
            }
            
            scheduledTasks.append(task)
        }
    }
    
    
    func removeNotificationSchedules() {
    }
    
    
    func createNotificationIdentifier(taskIdentifier: String, fireHour: Int) -> String {
        
        return taskIdentifier + String(describing: fireHour)
    }
    
}
