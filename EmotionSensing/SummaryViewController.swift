//
//  SummaryViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 2/4/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import AWAREFramework

class SummaryViewController: UIViewController, UNUserNotificationCenterDelegate {

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
        
        let hrvSensor = ScoscheHRV(awareStudy: study)
        manager.add(hrvSensor!)
        
        let accelerometer = Accelerometer(awareStudy: study)
        manager.add(accelerometer!)
        
        let stopSigalTaskResponse = StopSignalTaskResponse(awareStudy: study)
        manager.add(stopSigalTaskResponse!)
        
        manager.createDBTablesOnAwareServer()
        awareCore.requestPermissionForPushNotification()
        
        manager.startAllSensors()
        manager.syncAllSensors()

//        startESMTask()
        
        let task = UserTask(title: "Stop Signal Task", message: "Please complete the Stop Signal Task.", identifier: STOP_SIGNAL_TASK_IDENTIFIER, fireHours: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], expirationThreshold: 0, notificationDelegate: self)
//                let task = UserTask(title: "Stop Signal Task", message: "Please complete the Stop Signal Task.", identifier: STOP_SIGNAL_TASK_IDENTIFIER, fireHours: [21, 22], expirationThreshold: 0, notificationDelegate: self)
        let taskScheduler = UserTaskScheduler.shared
        taskScheduler.scheduleTask(task)
        taskScheduler.refrshNotificationSchedules()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let esmManager = ESMScheduleManager.shared()
        let schedules = esmManager.getValidSchedules()
        if (schedules.count > 0){
            print(schedules)
        }
        
    }
    
    
    
//    func scheduleExperienceSampling(){
//        let schedule = ESMSchedule.init()
//        schedule.notificationTitle = "notification title"
//        schedule.notificationBody = "notificaiton body"
//        schedule.scheduleId = "schedule_id"
//        schedule.expirationThreshold = 60
//        schedule.startDate = Date.init()
//        schedule.endDate = Date.init(timeIntervalSinceNow: 60*60*24*10)
//        schedule.fireHours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
//
//        let radio = ESMItem.init(asRadioESMWithTrigger: "1_radio", radioItems: ["A", "B", "C", "D", "E"])
//        radio?.setTitle("ESM title")
//        radio?.setInstructions("some instructions")
//        schedule.addESM(radio)
//
//        let esmManager = ESMScheduleManager.shared()
//        esmManager.add(schedule)
//        esmManager.refreshESMNotifications()
//
//    }
    
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
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Will receive notification")
        completionHandler([.alert, .sound])
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Did received notificaiton")
        
        let identifier = response.notification.request.content.categoryIdentifier
//        print("Controller: \(String(describing: viewController.self))")
        
        print("Task identifier:", identifier)
        let viewController = UIStoryboard(name: identifier, bundle: nil).instantiateViewController(withIdentifier: identifier)
        show(viewController, sender: self)
        
        // Open the Stop-Signal-Task tab
        self.tabBarController?.selectedIndex = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
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


}

