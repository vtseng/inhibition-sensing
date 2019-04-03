//
//  StopSignalTaskViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/1/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit
import AWAREFramework

// Stop-signal task settings
let FIXATION_DURATION = 2.0 // fixation duration
//let BLANK_DURATION = 0.2 // 0.2 sec blank duration
let GO_TRIAL_DURATION = 1.0

let NUMBER_OF_TOTAL_TRAILS = 30
let NUMBER_OF_STOP_TRIALS = 5

enum Signal {
    case leftGo, rightGo, stopFollowingLeftGo, stopFollowingRightGo
}

enum UserResponse {
    case left, right
}

enum TaskState {
    case blank, fixation, go, stop
}

class StopSignalTaskViewController: ViewController{
    
    @IBOutlet weak var fixationLabel: UILabel!
    @IBOutlet var taskView: UIView!
    
    var remainingNumberOfTrials : Int!
    var signal: Signal?
    var goSignalAppearedDate : Date?
    var taskState = TaskState.blank
    var trials : [TaskState]?
    var stopSignalDelay = 0.2 // Initial SSD = 200 ms
    var trialStartDate : Date?
    var responseDate : Date?
//    var goSignalRespondedTime: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remainingNumberOfTrials = NUMBER_OF_TOTAL_TRAILS
        
        let numberOfGoTrials = NUMBER_OF_TOTAL_TRAILS - NUMBER_OF_STOP_TRIALS
        let goTrials = Array(repeating: TaskState.go, count: numberOfGoTrials)
        let stopTrials = Array(repeating: TaskState.stop, count: NUMBER_OF_STOP_TRIALS)
        trials = (goTrials + stopTrials).shuffled()
        
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
            
            let goSignalRespondedDate = Date()
            
            if (goSignalAppearedDate != nil){
                let goResponseTime = goSignalRespondedDate.timeIntervalSince(goSignalAppearedDate!)
//                print("Go response time: \(goResponseTime)")
            }
            
            
            // After user responded to the signal, goSignalAppearedDate becomes nil
            goSignalAppearedDate = nil
            
        }
    }
    
    
    func userResponded(at touchPosition: CGPoint){
        var response: UserResponse?
        if touchPosition.x < taskView.frame.size.width/2 {
            response = .left
        } else {
            response = .right
        }
        
        switch taskState{
        case .blank:
            fixationLabel.text = ""
        case .fixation:
            fixationLabel.text = "Too early"
        case .stop:
            fixationLabel.text = "Incorrect"
        case .go:
            let correct = userResponseToGoTrial(with: response!)
            if correct{
                fixationLabel.text = "Correct"
            } else{
                fixationLabel.text = "Incorrect"
            }
        }
        fixationLabel.isHidden = false
    }
    
    
    @objc func showFixation(){
        taskState = .fixation
        goSignalAppearedDate = nil
        print("Showing Central Fixation")
        fixationLabel.text = "+"
        
        let nextTrial = trials?.popLast()
        
        if nextTrial == .go {
            Timer.scheduledTimer(timeInterval: FIXATION_DURATION, target: self, selector: #selector(startGoTrial), userInfo: nil, repeats: false)
        }else if nextTrial == .stop{
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
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(showBlank), userInfo: nil, repeats: false)
    }
    
    
    @objc func startStopTrial(){
        taskState = .stop
        print("Start trial")
        
        signal = stopSignalGenerator()
        
        if signal == .stopFollowingLeftGo {
            fixationLabel.text = "Left Stop"
        } else if signal == .stopFollowingRightGo {
            fixationLabel.text = "Right Stop"
        }
        
        trialStartDate = Date()
        
        Timer.scheduledTimer(timeInterval: stopSignalDelay, target: self, selector: #selector(showStopSignal), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(showBlank), userInfo: nil, repeats: false)
    }
    
    
    @objc func showBlank(){
        taskState = .blank
        //TODO: Save the log from the previvous trial
        var responseTime = -1.0
        if responseDate != nil{
            responseTime = responseDate!.timeIntervalSince(trialStartDate!)
            print("RT: \(responseTime)")
        }
        
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
        fixationLabel.text = "Completed"
    }

    
    func userResponseToGoTrial(with response: UserResponse) -> Bool{
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
