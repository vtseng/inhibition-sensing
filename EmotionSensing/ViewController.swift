//
//  ViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 2/4/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import AWAREFramework


class ViewController: UIViewController {

//    var sensorManager: AWARESensorManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let accelerometer = Accelerometer()
        accelerometer.setSensorEventHandler{ (sensor, data) in
            print(data)
        }
        
        accelerometer.startSensor()
        
    }


}

