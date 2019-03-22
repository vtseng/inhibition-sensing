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
    
    var ICStudy : InhibitionStudy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        
        let awareCore = AWARECore.shared()
        let study = AWAREStudy.shared()
        let manager = AWARESensorManager.shared()
        
        
//        let url = "https://api.awareframework.com/index.php/webservice/index/2223/VJ6qJn5ee2Fw"
        let url = "http://3.16.129.117/pac-server/index.php/webservice/index/key/example"
//        let url = "http://3.16.129.117/pac-server/index.php/webservice"
        
        study.join(withURL: url, completion: { (settings, studyState, error) in
            
            let accelerometer = Accelerometer(awareStudy: study)
            let ambientNoise = AmbientNoise(awareStudy: study)
            let locations = Locations(awareStudy: study)
            let iosActivity = IOSActivityRecognition(awareStudy: study)
            
//            let rotation = Rotation(awareStudy: study)
//            rotation?.startSensor()
//            rotation?.startSyncDB()
//            let network = Network(awareStudy: study)
//            network?.startSensor()
            
//            let battery = Battery(awareStudy: study)
//            battery?.startSensor()
            
            manager.add(accelerometer!)
//            manager.add(ambientNoise!)
            manager.add(locations!)
            manager.add(iosActivity!)
            
            manager.createDBTablesOnAwareServer()
            
            manager.startAllSensors()
            manager.syncAllSensors()
        })

    }


}

