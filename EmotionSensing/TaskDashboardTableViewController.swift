//
//  TaskDashboardTableViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/8/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit

class TaskDashboardTableViewController: UITableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")
//        cell!.textLabel?.text = "Stop Signal Task"
        
        return cell!
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
