//
//  TaskDashboardTableViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/8/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

let KEY_ATTEMPTED_TASKS = "attempted_tasks"

class PendingTaskCell: UITableViewCell {
    
    @IBOutlet weak var taskDisplayNameLabel: UILabel!
}

class PendingTasksTableViewController: UITableViewController {
    
//    var pendingTasks: [UserTask]!
    var pendingTaskIdentifiers: [String]!
    
    @IBOutlet var noPendingTasksView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        tableView.backgroundView = noPendingTasksView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let attemptedTasks = getRecentAttemptedTasks()
        pendingTaskIdentifiers = []
        
        for (taskIdentifier, fireDate) in UserTaskScheduler.shared.getPendingTasks() {
            if attemptedTasks[taskIdentifier] == nil {
                pendingTaskIdentifiers.append(taskIdentifier)
            } else if fireDate > attemptedTasks[taskIdentifier]! {
                pendingTaskIdentifiers.append(taskIdentifier)
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = pendingTaskIdentifiers.count
        
        if pendingTaskIdentifiers.count == 0 {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
            return 0
        } else {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingTaskIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskIdentifier = pendingTaskIdentifiers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingTaskCell") as! PendingTaskCell
        
        cell.taskDisplayNameLabel.text = UserTaskScheduler.shared.getTaskDisplayName(taskIentifier: taskIdentifier)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboardName = pendingTaskIdentifiers[indexPath.row]
        let taskIdentifier = pendingTaskIdentifiers[indexPath.row]
    
        
        let taskViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: taskIdentifier)
        //navigationController?.present(taskViewController, animated: true, completion: nil)
        navigationController?.pushViewController(taskViewController, animated: true)
    }
    
    
    /* Get tasks recently attempted.
    Meanwhile, update the dictionary to include only tasks attempted within the past 24 hours. */
    func getRecentAttemptedTasks() -> [String: Date] {
        let defaults = UserDefaults.standard
        
        var attemptedTasks = defaults.object(forKey: KEY_ATTEMPTED_TASKS) as? [String : Date]
        
        if attemptedTasks != nil{
            for (task, date) in attemptedTasks! {
                if Date().timeIntervalSince(date) > 24*60*60 {
                    attemptedTasks!.removeValue(forKey: task)
                }
            }
            defaults.set(attemptedTasks, forKey: KEY_ATTEMPTED_TASKS)
            
            return attemptedTasks!
        } else {
            return [:]
        }
        
    }
}
