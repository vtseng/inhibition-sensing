//
//  StopSignalTaskIntroductionViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/8/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit

let taskInstructions : String = "Below are the instructions for Stop Signal Task"

class StopSignalTaskInstructionsVeiwController: UIViewController{

    @IBOutlet weak var taskInstructionsLabel: UILabel!
    
    @IBAction func startTask(_ sender: Any) {
        
        // Update the UserDefaults when task is attempted
        let defaults = UserDefaults.standard
        var attemptedTasks : [String : Date] = [:]
        
        if let dict = defaults.object(forKey: KEY_ATTEMPTED_TASKS) as? [String : Date] {
            attemptedTasks = dict
        }
        
        attemptedTasks[STOP_SIGNAL_TASK_IDENTIFIER] = Date()
        defaults.set(attemptedTasks, forKey: KEY_ATTEMPTED_TASKS)
    }
    
    
}
