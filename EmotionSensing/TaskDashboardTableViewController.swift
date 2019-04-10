//
//  TaskDashboardTableViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/8/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit

class PendingTaskCell: UITableViewCell{
    
    @IBOutlet weak var taskNameLabel: UILabel!
}


class TaskDashboardTableViewController: UITableViewController{
    
    var userTaskScheduler: UserTaskScheduler!
    var pendingTasks: [UserTask]!

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pendingTasks = UserTaskScheduler.shared.getPendingTasks()
        return pendingTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = pendingTasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingTaskCell") as! PendingTaskCell
        
        cell.taskNameLabel.text = task.title
        
        return cell

        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboardName = "StopSignalTask"
        let taskIdentifier = "StopSignalTask"
        
        print("Index path: \(indexPath.row)")
        
        let taskViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: taskIdentifier)
        //navigationController?.present(taskViewController, animated: true, completion: nil)
        navigationController?.pushViewController(taskViewController, animated: true)
    }
    
}
