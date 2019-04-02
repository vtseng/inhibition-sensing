//
//  ViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 2/4/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import AWAREFramework

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

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
        
//        let hrvSensor = ScoscheHRV(awareStudy: study)
//        manager.add(hrvSensor!)
        
        let accelerometer = Accelerometer(awareStudy: study)
        manager.add(accelerometer!)
        
        manager.createDBTablesOnAwareServer()
        
        manager.startAllSensors()
        manager.syncAllSensors()
        
        awareCore.requestPermissionForPushNotification()
        startESMTask()
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let esmManager = ESMScheduleManager.shared()
        let schedules = esmManager.getValidSchedules()
        if (schedules.count > 0){
            print(schedules)
        }
        
    }
    
    
    
    func scheduleExperienceSampling(){
        let schedule = ESMSchedule.init()
        schedule.notificationTitle = "notification title"
        schedule.notificationBody = "notificaiton body"
        schedule.scheduleId = "schedule_id"
        schedule.expirationThreshold = 60
        schedule.startDate = Date.init()
        schedule.endDate = Date.init(timeIntervalSinceNow: 60*60*24*10)
        schedule.fireHours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
        
        let radio = ESMItem.init(asRadioESMWithTrigger: "1_radio", radioItems: ["A", "B", "C", "D", "E"])
        radio?.setTitle("ESM title")
        radio?.setInstructions("some instructions")
        schedule.addESM(radio)
        
        let esmManager = ESMScheduleManager.shared()
        esmManager.add(schedule)
        esmManager.refreshESMNotifications()
        
    }
    
    func startESMTask(){
        let content = UNMutableNotificationContent()
        content.title = "Task title"
        content.subtitle = "Task subtitle"
        content.body = "Task body"
        content.categoryIdentifier = "taskIdentifier"
        content.badge = 1
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 3
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "TaskNotificaiton", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Did received notificaiton")
        // Open the Stop-Signal-Task tab
        self.tabBarController?.selectedIndex = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    

}

