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
//    var hrvSensor: ScoscheHRV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let awareCore = AWARECore.shared()
        let study = AWAREStudy.shared()
        let manager = AWARESensorManager.shared()
        

        let url = "http://3.16.129.117/pac-server/index.php/webservice/index/key/example"
        study.setStudyURL(url)
        
        let hrvSensor = ScoscheHRV(awareStudy: study)
        manager.add(hrvSensor!)
        
        let accelerometer = Accelerometer(awareStudy: study)
        manager.add(accelerometer!)
        
        manager.createDBTablesOnAwareServer()
        
        manager.startAllSensors()
        manager.syncAllSensors()
        
    
        
//        study.join(withURL: url) { (settings, studyState, error) in
//            let accelerometer = Accelerometer()
//            manager.add(accelerometer)
//
//            let hrvSensor = ScoscheHRV()
//            manager.add(hrvSensor)
//
//            manager.createDBTablesOnAwareServer()
//
//            manager.startAllSensors()
//            manager.syncAllSensors()
//
//        }
    
    }

}

