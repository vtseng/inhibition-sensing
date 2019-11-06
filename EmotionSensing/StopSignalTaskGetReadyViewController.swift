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
    
    @IBOutlet weak var taskWillStartLabel: UILabel!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var heartRateMonitorNotConnectedLabel: UILabel!
    
    var taskHasStarted : Bool!
    var hrvDataIsAvailable: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(onMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(BLESensorDidUpdateRRInterval),
                                       name: .ScoscheDidUpdateRRInterval,
                                       object: nil)
        taskHasStarted = false
        hrvDataIsAvailable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        hrvDataIsAvailable = false
        updateView()
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
        
        taskHasStarted = true
        
        performSegue(withIdentifier: "startStopSignalTask", sender: self)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if taskHasStarted {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func BLESensorDidUpdateRRInterval() {
        hrvDataIsAvailable = true
        updateView()
    }
    
    
    func updateView() {
        taskWillStartLabel.isHidden = true
        taskCompletionLabel.isHidden = true
        startButton.isHidden = true
        heartRateMonitorNotConnectedLabel.isHidden = true
        
        if taskHasStarted {
            //taskWillStartLabel.isHidden = true
            //startButton.isHidden = true
            taskCompletionLabel.isHidden = false
            //heartRateMonitorNotConnectedLabel.isHidden = true
        } else if hrvDataIsAvailable {
            taskWillStartLabel.isHidden = false
            startButton.isHidden = false
            //taskCompletionLabel.isHidden = true
            //heartRateMonitorNotConnectedLabel.isHidden = true
        } else {
            //taskWillStartLabel.isHidden = true
            //startButton.isHidden = true
            //taskCompletionLabel.isHidden = true
            heartRateMonitorNotConnectedLabel.isHidden = false
        }
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
