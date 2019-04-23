//
//  StopSignalTaskGetReadyViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/22/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit

class StopSignalTaskGetReadyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(onMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    
    @objc func onMovedToBackground() {
        dismiss(animated: true, completion: nil)
    }
    
    
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
    
    
    
    // MARK: Force the screen to auto to the right.
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .landscapeRight
    }
}
