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

let NUMBER_OF_TRIALS = 30

enum Trial {
    case Go, Stop
}

enum Signal {
    case leftGo, rightGo, stopFollowingLeftGo, stopFollowingRightGo
}

enum UserResponse {
    case left, right
}

class StopSignalTaskViewController: ViewController{
    
    @IBOutlet weak var fixationLabel: UILabel!
    @IBOutlet var taskView: UIView!
    
    var remainingNumberOfTrials : Int!
    var signal: Signal?
    var goSignalAppearedDate : Date?
//    var goSignalRespondedTime: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remainingNumberOfTrials = NUMBER_OF_TRIALS
        showCentralFixation()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let position = touch.location(in: taskView)
//            print(position)
            fixationLabel.isHidden = true
            let response = userResponded(at: position)
            
            let goSignalRespondedDate = Date()
//            let goSignalRespondedTimestamp = AWAREUtils.getUnixTimestamp(Date())!
//            print("Responded: \(goSignalRespondedTimestamp)")
            
            if (goSignalAppearedDate != nil){
//                let goResponseTime = goSignalRespondedTimestamp.floatValue - goSignalAppearedTimestamp!.floatValue
                let goResponseTime = goSignalRespondedDate.timeIntervalSince(goSignalAppearedDate!)
//                print("Go appeared: \(goSignalAppearedDate)")
                print("Go responded: \(goSignalRespondedDate)")
                print("Go response time: \(goResponseTime)")
            }
            
            
            // After user responded to the signal, goSignalAppearedDate becomes nil
            goSignalAppearedDate = nil
            
        }
    }
    
    func userResponded(at touchPosition: CGPoint) -> UserResponse{
        if (touchPosition.x < taskView.frame.size.width/2){
            return .left
        }else{
            return .right
        }
    }
    

    // The duration for which the central fixation stays
    @objc func showCentralFixation(){
        goSignalAppearedDate = nil
        print("Showing Central Fixation")
        remainingNumberOfTrials -= 1
        fixationLabel.text = "+"
        fixationLabel.isHidden = false
        Timer.scheduledTimer(timeInterval: FIXATION_DURATION, target: self, selector: #selector(startGoTrial), userInfo: nil, repeats: false)
    }
    
    @objc func startGoTrial(){
        // Randomly decide the type of Go signal
        let signal = Signal.leftGo
        
        if (signal == .leftGo){
            fixationLabel.text = "Left"
        }else if (signal == .rightGo){
            fixationLabel.text = "Right"
        }
        
        print("Go trial starts")
        goSignalAppearedDate = Date()
//        goSignalAppearedTimestamp = AWAREUtils.getUnixTimestamp(Date())
        print("Appeared: \(goSignalAppearedDate!)")
        
        
        
        if (remainingNumberOfTrials > 0){
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(showCentralFixation), userInfo: nil, repeats: false)
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
