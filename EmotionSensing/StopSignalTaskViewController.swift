//
//  StopSignalTaskViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/1/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AWAREFramework

enum Signal {
    case leftGo, rightGo, stopFollowingLeftGo, stopFollowingRightGo
}

enum TouchResponse {
    case left, right
}

enum TaskState: String {
    case blank = "blank"
    case fixation = "fixation"
    case go = "go"
    case stop = "stop"
    case completed = "completed"
}

enum ResponseType: String {
    case falseStart = "false_start"
    case goCorrect = "go_correct"
    case goOmission = "go_omission"
    case goError = "go_error"
    case stopSuccessful = "stop_successful"
    case stopUnsuccessful = "stop_unsuccessful"
}

enum TaskStatus: String {
    case incomplete = "incomplete"
    case complete = "complete"
}

// Stop-signal task settings
let fixationDuration = 1.5 // fixation duration
let trialDuration = 1.5
let initialStopSignalDelay = 0.25
let stopSignalDelayStepSize = 0.025 // After successful stopping SSD was increased by 25ms and after unsuccessful stopping SSD was decreased by 25ms.

let numberOfTotalTrials = 10
let numberOfStopTrials = 5

let defaultGoResponseType = ResponseType.goOmission // Default response type for Go trial if user doesn't respond
let defaultStopResponseType = ResponseType.stopSuccessful // Default response type for Stop trial if user doesn't respond

let KEY_STOP_SIGNAL_TASK_NUMBER_STOP_TRIALS = "number_stop_trials"
let KEY_STOP_SIGNAL_TASK_NUMBER_TOTAL_TRIALS = "number_total_trials"
let KEY_STOP_SIGNAL_TRIAL_ID = "trial_id"
let KEY_STOP_SIGNAL_TASK_RESPONSE_TIME = "response_time_milliseconds"
let KEY_STOP_SIGNAL_TASK_STOP_SIGNAL_DELAY = "stop_signal_delay_milliseconds"
let KEY_STOP_SIGNAL_TASK_START_TIMESTAMP = "task_start_timestamp"
let KEY_STOP_SIGNAL_TASK_TIMESTAMP = "timestamp"
let KEY_STOP_SIGNAL_TASK_DEVICE_ID = "device_id"
let KEY_STOP_SIGNAL_TASK_RESPONSE_TYPE = "response_type"
let KEY_STOP_SIGNAL_TASK_TRIAL_TYPE = "trial_type"


let fileName  = "task.csv"
let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

class StopSignalTaskViewController: UIViewController{
    
    @IBOutlet weak var fixationLabel: UILabel!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet var taskView: UIView!
    
    var signal: Signal?
    var goSignalAppearedDate : Date?
    var taskState = TaskState.blank
    var trials : [TaskState]?
    var stopSignalDelay = 0.25 // Initial SSD = 250 ms
    var trialStartDate : Date?
    var responseDate : Date?
    var responseType : ResponseType?
    var userDidRespond = false
    var taskStartTimestamp : NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberOfGoTrials = numberOfTotalTrials - numberOfStopTrials
        let goTrials = Array(repeating: TaskState.go, count: numberOfGoTrials)
        let stopTrials = Array(repeating: TaskState.stop, count: numberOfStopTrials)
        trials = (goTrials + stopTrials).shuffled()
        responseType = nil
        taskStartTimestamp = AWAREUtils.getUnixTimestamp(Date())
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(onMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        taskCompletionLabel.isHidden = true
        fixationLabel.isHidden = true
        showFixation()
        
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responseDate == nil {
            responseDate = Date()
        }
        
        if let touch = touches.first{
            let position = touch.location(in: taskView)
            fixationLabel.isHidden = true
            userResponded(at: position)
            
        }
    }
    
    
    func userResponded(at touchPosition: CGPoint){
        var touchResponse: TouchResponse?
        if touchPosition.x < taskView.frame.size.width/2 {
            touchResponse = .left
        } else {
            touchResponse = .right
        }
        
        resetLabelTextStyle()
        
        switch taskState{
        case .blank:
            fixationLabel.text = ""
            
        case .fixation:
            fixationLabel.text = "Too early"
            responseType = .falseStart
            
        case .stop:
            fixationLabel.text = userDidRespond ? fixationLabel.text : "Incorrect"
            responseType = userDidRespond ?  responseType : .stopUnsuccessful
            
        case .go:
            let correct = userResponseToGoTrial(with: touchResponse!)
            if correct{
                fixationLabel.text = userDidRespond ? fixationLabel.text : "Correct"
                responseType = userDidRespond ? responseType : .goCorrect
            } else{
                fixationLabel.text = userDidRespond ? fixationLabel.text : "Incorrect"
                responseType = userDidRespond ? responseType : .goError
            }
            
        case .completed:
            self.dismiss(animated: true, completion: nil)
        }
        
        userDidRespond = true
        fixationLabel.isHidden = false
    }
    
    
    @objc func showFixation(){
        taskState = .fixation
        fixationLabel.text = "+"
        fixationLabel.isHidden = false
        goSignalAppearedDate = nil
        userDidRespond = false
        
        let nextTrial = trials?.popLast()
        
        if nextTrial == .go {
            responseType = defaultGoResponseType
            Timer.scheduledTimer(timeInterval: fixationDuration, target: self, selector: #selector(startGoTrial), userInfo: nil, repeats: false)
        }else if nextTrial == .stop {
            responseType = defaultStopResponseType
            Timer.scheduledTimer(timeInterval: fixationDuration, target: self, selector: #selector(startStopTrial), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func startGoTrial(){
        taskState = .go
        print("Go trial")
        
        // Randomly decide the type of Go signal
        signal = goSignalGenerator()
        showGoSignal(signal: signal!)
        
        trialStartDate = Date()
        
        Timer.scheduledTimer(timeInterval: trialDuration, target: self, selector: #selector(showBlank), userInfo: nil, repeats: false)
    }
    
    
    @objc func startStopTrial(){
        taskState = .stop
        print("Start trial")
        
        signal = stopSignalGenerator()
        showGoSignal(signal: signal!)

        trialStartDate = Date()
        
        Timer.scheduledTimer(timeInterval: stopSignalDelay, target: self, selector: #selector(showStopSignal), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: trialDuration, target: self, selector: #selector(showBlank), userInfo: nil, repeats: false)
    }
    
    
    @objc func showBlank(){
        //TODO: Save the log from the previvous trial
        var responseTime = -1.0
        if responseDate != nil {
            responseTime = responseDate!.timeIntervalSince(trialStartDate!)
        }
        
        print("RT: \(responseTime)")
        print("Re: \(responseType!.rawValue)")
    
        let trial_id = numberOfTotalTrials - trials!.count
        let response_timestamp = AWAREUtils.getUnixTimestamp(Date())
        let device_id = AWAREStudy.shared().getDeviceId()
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = CoreDataHandler.shared().persistentStoreCoordinator
        let task = NSEntityDescription.insertNewObject(forEntityName: String(describing: EntityStopSignalTask.self), into: managedObjectContext)
        
        task.setValue(numberOfStopTrials, forKey: KEY_STOP_SIGNAL_TASK_NUMBER_STOP_TRIALS)
        task.setValue(numberOfTotalTrials, forKey: KEY_STOP_SIGNAL_TASK_NUMBER_TOTAL_TRIALS)
        task.setValue(trial_id, forKey: KEY_STOP_SIGNAL_TRIAL_ID)
        task.setValue(responseTime*1000, forKey: KEY_STOP_SIGNAL_TASK_RESPONSE_TIME)
        task.setValue(stopSignalDelay*1000, forKey: KEY_STOP_SIGNAL_TASK_STOP_SIGNAL_DELAY)
        task.setValue(taskStartTimestamp, forKey: KEY_STOP_SIGNAL_TASK_START_TIMESTAMP)
        task.setValue(response_timestamp, forKey: KEY_STOP_SIGNAL_TASK_TIMESTAMP)
        task.setValue(device_id, forKey: KEY_STOP_SIGNAL_TASK_DEVICE_ID)
        task.setValue(responseType!.rawValue, forKey: KEY_STOP_SIGNAL_TASK_RESPONSE_TYPE)
        task.setValue(taskState.rawValue, forKey: KEY_STOP_SIGNAL_TASK_TRIAL_TYPE)
    
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        // Update the next stop signal delay
        if taskState == .stop {
            if responseType == .stopSuccessful {
                stopSignalDelay += stopSignalDelayStepSize
            } else {
                stopSignalDelay -= stopSignalDelayStepSize
            }
        }
        
        
        taskState = .blank
        resetLabelTextStyle()
        trialStartDate = nil
        responseDate = nil
        
        if trials!.count > 0 {
            showFixation()
        } else{
            taskState = .completed
            taskDidComplete()
        }
    }
    
    
    func showGoSignal(signal: Signal) {
        fixationLabel.isHidden = true
        resetLabelTextStyle()
        
        if signal == .leftGo || signal == .stopFollowingLeftGo  {
            fixationLabel.text = "L"
        } else if signal == .rightGo || signal == .stopFollowingRightGo {
            fixationLabel.text = "R"
        }
        
        fixationLabel.isHidden = false
    }
    
    
    @objc func showStopSignal(){
        fixationLabel.isHidden = true
        fixationLabel.textColor = UIColor.red
        fixationLabel.text = "X"
        fixationLabel.font = UIFont.systemFont(ofSize: 40)
        fixationLabel.isHidden = false
    }
    
    
    
    func taskDidComplete(){
        fixationLabel.isHidden = true
        taskCompletionLabel.isHidden = false
        
        // Update the number of completed tasks
        let defaults = UserDefaults.standard
        var numberOfCompletedTasks = 0
        if let number = defaults.object(forKey: KEY_NUMBER_COMPLETED_TASKS) as? Int {
            numberOfCompletedTasks = number
        }
        numberOfCompletedTasks += 1
        defaults.set(numberOfCompletedTasks, forKey: KEY_NUMBER_COMPLETED_TASKS)
        
    }

    
    func userResponseToGoTrial(with response: TouchResponse) -> Bool{
        if signal == .leftGo && response == .left {
            return true
        } else if signal == .rightGo && response == .right {
            return true
        } else {
            return false
        }
    }
    
    
    func goSignalGenerator() -> Signal{
        let flippedHead = Bool.random()
        if flippedHead {
            return .leftGo
        } else {
            return .rightGo
        }
    }
    
    
    func stopSignalGenerator() -> Signal {
        let flippedHead = Bool.random()
        if flippedHead {
            return .stopFollowingLeftGo
        } else {
            return .stopFollowingRightGo
        }
    }
    
    
    @objc func onMovedToBackground() {
        // TODO: Save unsaved user data before the view coontroller gets removed
        print("Task moved to background!")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func resetLabelTextStyle() {
        fixationLabel.textColor = UIColor.black
        fixationLabel.font = UIFont.systemFont(ofSize: 40)
    }
    
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
