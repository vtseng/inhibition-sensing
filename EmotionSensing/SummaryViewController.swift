//
//  SummaryViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 2/4/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import AWAREFramework

let KEY_NUMBER_COMPLETED_TASKS = "number_completed_tasks"

class SummaryViewController: UIViewController, UNUserNotificationCenterDelegate {

//    var sensorManager: AWARESensorManager?
//    var hrvSensor: ScoscheHRV!
    
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var batteryLevelValueLabel: UILabel!
    @IBOutlet weak var rrIntervalLabel: UILabel!
    @IBOutlet weak var rrIntervalValueLabel: UILabel!
    
    var numberOfCompletedTasks: Int!
    
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
        study.setMaximumNumberOfRecordsForDBSync(1)
        
        let hrvSensor = ScoscheHRV(awareStudy: study)
        manager.add(hrvSensor!)
        
        let accelerometer = Accelerometer(awareStudy: study)
        manager.add(accelerometer!)
        
        let stopSigalTaskResponse = StopSignalTaskResponse(awareStudy: study)
        manager.add(stopSigalTaskResponse!)
        
        let weather = OpenWeather(awareStudy: study)
        manager.add(weather!)
        
        let iosActivity = IOSActivityRecognition(awareStudy: study)
        manager.add(iosActivity!)
        
        let ambientNoise = AmbientNoise(awareStudy: study)
        manager.add(ambientNoise!)
        
        let locations = Locations(awareStudy: study)
        manager.add(locations!)
        
        let battery = Battery(awareStudy: study)
        manager.add(battery!)
        
        let calendar = Calendar(awareStudy: study)
        manager.add(calendar!)
        
        let calls = Calls(awareStudy: study)
        manager.add(calls!)
        
        let deviceUsage = DeviceUsage(awareStudy: study)
        manager.add(deviceUsage!)
        
        let pushNotification = PushNotification(awareStudy: study)
        manager.add(pushNotification!)
        
        let screen = Screen(awareStudy: study)
        manager.add(screen!)
        
        let visitLocations = VisitLocations(awareStudy: study)
        manager.add(visitLocations!)

        let pedometer = Pedometer(awareStudy: study)
        manager.add(pedometer!)
        
        manager.createDBTablesOnAwareServer()
        awareCore.requestPermissionForPushNotification()
        
        manager.startAllSensors()
        
        let task = UserTask(title: "Stop Signal Task", message: "Please complete the Stop Signal Task.", identifier: STOP_SIGNAL_TASK_IDENTIFIER, fireHours: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], expirationThreshold: 55, notificationDelegate: tabBarController as! UNUserNotificationCenterDelegate)
        let taskScheduler = UserTaskScheduler.shared
        taskScheduler.scheduleTask(task)
        taskScheduler.refrshNotificationSchedules()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        if let number = defaults.object(forKey: KEY_NUMBER_COMPLETED_TASKS) as? Int {
            numberOfCompletedTasks = number
        } else {
            numberOfCompletedTasks = 0
        }
        
        print("#Completed tasks: \(numberOfCompletedTasks)")
    }
    
    
    func startESMTask(){
        let content = UNMutableNotificationContent()
        content.title = "Task title"
        content.subtitle = "Task subtitle"
        content.body = "Task body"
        content.categoryIdentifier = STOP_SIGNAL_TASK_IDENTIFIER
        content.badge = 1
        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 44
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: STOP_SIGNAL_TASK_IDENTIFIER, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("Notification error \(String(describing: error))")
            }
            
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    
    // MARK: User reminders
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


    @objc func appMovedToBackground() {
        print("Sync data after App moved to background!")
        AWARESensorManager.shared().syncAllSensorsForcefully()
    }
}

