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
    var hrvSensor: ScoscheHRV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        hrvSensor = ScoscheHRV()
        hrvSensor.startSensor()

//        let accelerometer = Accelerometer()
//        accelerometer.startSensor()
//
//        let ambientNoise = AmbientNoise()
//        ambientNoise.startSensor()
    
    }

}

