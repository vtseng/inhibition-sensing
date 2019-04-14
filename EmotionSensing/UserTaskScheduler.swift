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
let FIRE_MINUTE_COMPONENT = 39

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
    
    
    func getPendingTasks() -> [String : Date] {
//        var pendingTasks: [UserTask] = []
        var pendingTasks: [String : Date] = [:] // The fire date of each of the tasks, keyed by the task identifier.
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        
        for task in scheduledTasks {
            var fireDateComponents = dateComponents
            for hour in task.fireHous! {
                fireDateComponents.timeZone = TimeZone.current
                fireDateComponents.hour = hour
                fireDateComponents.minute = FIRE_MINUTE_COMPONENT

                
                let fireDate = calendar.date(from: fireDateComponents)!
                
                if Date() > fireDate && Date() < fireDate.addingTimeInterval(TimeInterval(task.expirationThreshold*60)) {
//                    pendingTasks.append(task)
                    pendingTasks[task.identifier] = fireDate
                }
                
            }
        }
        
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
                    dateComponents.minute = FIRE_MINUTE_COMPONENT
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let notificationIdentifier = getNotificationIdentifier(taskIdentifier: task.identifier, fireHour: hour)
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
    
    
    func getNotificationIdentifier(taskIdentifier: String, fireHour: Int) -> String {
        
        return taskIdentifier + String(describing: fireHour)
    }
    
}
