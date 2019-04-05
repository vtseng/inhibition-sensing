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
let FIXATION_DURATION = 2.0 // fixation duration
//let BLANK_DURATION = 0.2 // 0.2 sec blank duration
let GO_TRIAL_DURATION = 1.0

let NUMBER_OF_TOTAL_TRAILS = 10
let NUMBER_OF_STOP_TRIALS = 5

let DEFAULT_GO_RESPONSE_TYPE = ResponseType.goOmission // Default response type for Go trial if user doesn't respond
let DEFAULT_STOP_RESPONSE_TYPE = ResponseType.stopSuccessful // Default response type for Stop trial if user doesn't respond

let KEY_STOP_SIGNAL_TASK_DEVICE_ID = "device_id"
let KEY_STOP_SIGNAL_TASK_TIMESTAMP = "timestamp"
let KEY_STOP_SIGNAL_TASK_RESPONSE_STRING = "task_response_string"
let KEY_STOP_SIGNAL_TASK_STATUS = "task_status"


let fileName  = "task.csv"
let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

class StopSignalTaskViewController: ViewController{
    
    @IBOutlet weak var fixationLabel: UILabel!
    @IBOutlet var taskView: UIView!
    
    var signal: Signal?
    var goSignalAppearedDate : Date?
    var taskState = TaskState.blank
    var trials : [TaskState]?
    var stopSignalDelay = 0.2 // Initial SSD = 200 ms
    var trialStartDate : Date?
    var responseDate : Date?
    var responseType : ResponseType?
    var userDidRespond = false
    var responseString = "Trial ID, Trial Timestamp, Trial Type, Current SSD (ms), Response, Response Time (ms)\n"
    var taskStatus = TaskStatus.incomplete
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberOfGoTrials = NUMBER_OF_TOTAL_TRAILS - NUMBER_OF_STOP_TRIALS
        let goTrials = Array(repeating: TaskState.go, count: numberOfGoTrials)
        let stopTrials = Array(repeating: TaskState.stop, count: NUMBER_OF_STOP_TRIALS)
        trials = (goTrials + stopTrials).shuffled()
        
        responseType = nil
        
        
        showFixation()
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
        }
        
        userDidRespond = true
        fixationLabel.isHidden = false
    }
    
    
    @objc func showFixation(){
        taskState = .fixation
        goSignalAppearedDate = nil
        print("Showing Central Fixation")
        fixationLabel.text = "+"
        userDidRespond = false
        
        let nextTrial = trials?.popLast()
        
        if nextTrial == .go {
            responseType = DEFAULT_GO_RESPONSE_TYPE
            Timer.scheduledTimer(timeInterval: FIXATION_DURATION, target: self, selector: #selector(startGoTrial), userInfo: nil, repeats: false)
        }else if nextTrial == .stop {
            responseType = DEFAULT_STOP_RESPONSE_TYPE
            Timer.scheduledTimer(timeInterval: FIXATION_DURATION, target: self, selector: #selector(startStopTrial), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func startGoTrial(){
        taskState = .go
        print("Go trial")
        
        // Randomly decide the type of Go signal
        signal = goSignalGenerator()
        
        if signal == .leftGo {
            fixationLabel.text = "Left"
        } else if signal == .rightGo {
            fixationLabel.text = "Right"
        }
        
        trialStartDate = Date()
        
        Timer.scheduledTimer(timeInterval: GO_TRIAL_DURATION, target: self, selector: #selector(showBlank), userInfo: nil, repeats: false)
    }
    
    
    @objc func startStopTrial(){
        taskState = .stop
        print("Start trial")
        
        signal = stopSignalGenerator()
        
        if signal == .stopFollowingLeftGo {
            fixationLabel.text = "Left"
        } else if signal == .stopFollowingRightGo {
            fixationLabel.text = "Right"
        }
        
        trialStartDate = Date()
        
        Timer.scheduledTimer(timeInterval: stopSignalDelay, target: self, selector: #selector(showStopSignal), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(showBlank), userInfo: nil, repeats: false)
    }
    
    
    @objc func showBlank(){
        //TODO: Save the log from the previvous trial
        var responseTime = -1.0
        if responseDate != nil {
            responseTime = responseDate!.timeIntervalSince(trialStartDate!)
        }
        
        print("RT: \(responseTime)")
        print("Re: \(responseType!.rawValue)")
    
        let trial_id = NUMBER_OF_TOTAL_TRAILS - trials!.count
        let timestamp = AWAREUtils.getUnixTimestamp(Date())
        
        let trialResponseString = "\(trial_id),\(String(describing: timestamp!)),\(taskState.rawValue),\(stopSignalDelay*1000),\(String(describing: responseType!.rawValue)),\(responseTime*1000)\n"
        responseString.append(trialResponseString)
        
        taskState = .blank
        trialStartDate = nil
        responseDate = nil
        
        if trials!.count > 0 {
            showFixation()
        } else{
            taskDidComplete()
        }
    }
    
    
    @objc func showStopSignal(){
        fixationLabel.text = "X"
    }
    
    
    
    func taskDidComplete(){
        taskStatus = .complete
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = CoreDataHandler.shared().persistentStoreCoordinator
        

//        let task = EntityStopSignalTask()
        let task = NSEntityDescription.insertNewObject(forEntityName: String(describing: EntityStopSignalTask.self), into: managedObjectContext)
        
        let device_id = AWAREStudy.shared().getDeviceId()
        let unixtime = AWAREUtils.getUnixTimestamp(Date())
        task.setValue(device_id, forKey: KEY_STOP_SIGNAL_TASK_DEVICE_ID)
        task.setValue(unixtime, forKey: KEY_STOP_SIGNAL_TASK_TIMESTAMP)
        task.setValue(responseString, forKey: KEY_STOP_SIGNAL_TASK_RESPONSE_STRING)
        task.setValue(taskStatus.rawValue, forKey: KEY_STOP_SIGNAL_TASK_STATUS)
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        
        do {
            try responseString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        fixationLabel.text = "Completed"
        
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
    
    
    func stopSignalGenerator() -> Signal{
        let flippedHead = Bool.random()
        if flippedHead {
            return .stopFollowingLeftGo
        } else {
            return .stopFollowingRightGo
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Save unsaved user data
    }
    
    
    // MARK: Force the orientation to be landscape.
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
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
