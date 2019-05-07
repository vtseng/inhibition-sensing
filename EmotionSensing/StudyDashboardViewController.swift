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
let researcherPassword = "paclab"

class StudyDashboardViewController: UIViewController, UNUserNotificationCenterDelegate {

//    var sensorManager: AWARESensorManager?
//    var hrvSensor: ScoscheHRV!
    
    @IBOutlet weak var batteryLevelValueLabel: UILabel!
    @IBOutlet weak var rrIntervalValueLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var numberOfCompletedTasksLabel: UILabel!
    
//    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
    let reachability = Reachability(hostName: "www.google.com")
    
    var numberOfCompletedTasks: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonTapped))
        
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
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)

        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let url = "http://3.16.129.117/pac-server/index.php/webservice/index/key/example"
        study.setStudyURL(url)
        study.setMaximumNumberOfRecordsForDBSync(100)
        study.setAutoDBSyncOnlyBatterChargning(false)
        
        let hrvSensor = BLEHeartRateVariability(awareStudy: study)
        manager.add(hrvSensor!)
        
        //let accelerometer = Accelerometer(awareStudy: study)
        //manager.add(accelerometer!)
        
        let linearAccelerometer = LinearAccelerometer(awareStudy: study)
        manager.add(linearAccelerometer!)
        
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
        
        let wifi = Wifi(awareStudy: study)
        manager.add(wifi!)
        
        let bluetooth = Bluetooth(awareStudy: study)
        manager.add(bluetooth!)
        
        let network = Network(awareStudy: study)
        manager.add(network!)
        
        let proximity = Proximity(awareStudy: study)
        manager.add(proximity!)
        
        let selfControlEMA = SelfControlEMA(awareStudy: study)
        manager.add(selfControlEMA!)
        
        manager.createDBTablesOnAwareServer()
        awareCore.requestPermissionForPushNotification()
        
        
        manager.startAllSensors()
//        manager.syncAllSensors()
        
        let task = UserTask(title: "Stop Signal Task", message: "Please complete the Stop Signal Task.", identifier: STOP_SIGNAL_TASK_IDENTIFIER, fireHours: [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], expirationThreshold: 55, notificationDelegate: tabBarController as! UNUserNotificationCenterDelegate)
        let taskScheduler = UserTaskScheduler.shared
        taskScheduler.scheduleTask(task)
        taskScheduler.refrshNotificationSchedules()

        reachability?.startNotifier()
//        if ((reachability?.startNotifier())!){
//            print("Reachability started notifier")
//        }else {
//            print("Could not start reachability notifier")
//        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceIdLabel.text = AWAREStudy.shared().getDeviceId()
        
        let defaults = UserDefaults.standard
        if let number = defaults.object(forKey: KEY_NUMBER_COMPLETED_TASKS) as? Int {
            numberOfCompletedTasks = number
        } else {
            numberOfCompletedTasks = 0
        }
        numberOfCompletedTasksLabel.text = String(numberOfCompletedTasks)
    
    }
    
    @objc
    func scoscheDidUpdateBatteryLevel(_ notification: Notification) {
        let batteryLevel = notification.userInfo?[BLEHeartRateVariability.BATTERY_LEVEL_NOTIFICATION_KEY]
        self.batteryLevelValueLabel.text = "\(batteryLevel!)"
    }
    
    @objc
    func scoscheDidUpdateRRInterval(_ notification: Notification) {
        let rr = notification.userInfo?[BLEHeartRateVariability.RR_INTERVAL_NOTIFICATION_KEY]
        self.rrIntervalValueLabel.text = "\(rr!)"
    }


    @objc func appMovedToBackground() {
//        AWARESensorManager.shared().syncAllSensors()
    }
    
    
    @objc func resetButtonTapped() {
        let alert = UIAlertController(title: "Reset Study", message: "Please enter the password to reset the study.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { [weak alert, unowned self] (_) in
            let password = alert?.textFields![0].text
            if password == researcherPassword {
                UserDefaults.standard.set(nil, forKey: KEY_HRV_PERIPHERAL_ID)
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func willEnterForeground() {
        print("App entered foreground")
        AWARESensorManager.shared().startAllSensors()
        AWARESensorManager.shared().syncAllSensors()
    }
    

    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        print(reachability.currentReachabilityStatus())
        let status = reachability.currentReachabilityStatus()
        switch status {
        case NotReachable:
            print("Network not reachable")
        case ReachableViaWiFi:
            AWARESensorManager.shared().syncAllSensors()
            print("Network reachable via WIFI")
        case ReachableViaWWAN:
            print("Network reachable via WWAN")
        default:
            print("Network reachable via \(status.rawValue)")
        }
    }
    
}

