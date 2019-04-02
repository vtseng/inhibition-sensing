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
    
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var batteryLevelValueLabel: UILabel!
    @IBOutlet weak var rrIntervalLabel: UILabel!
    @IBOutlet weak var rrIntervalValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let awareCore = AWARECore.shared()
        let study = AWAREStudy.shared()
        let manager = AWARESensorManager.shared()
        
        // add observers for battery level and rr interval updates
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(scoscheDidUpdateBatteryLevel(_:)),
                                       name: .ScoscheDidUpdateBatteryLevel,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(scoscheDidUpdateRRInterval(_:)),
                                       name: .ScoscheDidUpdateRRInterval,
                                       object: nil)

        let url = "http://3.16.129.117/pac-server/index.php/webservice/index/key/example"
        study.setStudyURL(url)
        
        let hrvSensor = ScoscheHRV(awareStudy: study, dbType: AwareDBTypeSQLite)
        manager.add(hrvSensor!)
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
    
    @objc
    func scoscheDidUpdateBatteryLevel(_ notification: Notification) {
        let batteryLevel = notification.userInfo?[ScoscheHRV.BATTERY_LEVEL_NOTIFICATION_KEY]
        self.batteryLevelValueLabel.text = "\(batteryLevel!)"
    }
    
    @objc
    func scoscheDidUpdateRRInterval(_ notification: Notification) {
        let rr = notification.userInfo?[ScoscheHRV.RR_INTERVAL_NOTIFICATION_KEY]
        self.rrIntervalValueLabel.text = "\(rr!)"
    }

}

