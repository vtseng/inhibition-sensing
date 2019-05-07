//
//  TabBarViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import UserNotifications

class TabBarController : UITabBarController, UITabBarControllerDelegate, UNUserNotificationCenterDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        print("TabBar viewDidLoad!")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var studyViewController: UIViewController!
        
        studyViewController = UIStoryboard(name: "StudyDashboard", bundle: nil).instantiateViewController(withIdentifier: "BluetoothScan") as! BLEDevicesTableViewController
        let studyNavigationController = UINavigationController(rootViewController: studyViewController)
        studyNavigationController.title = "Dashboard"
        
        let taskViewController = UIStoryboard(name: "TaskDashboard", bundle: nil).instantiateViewController(withIdentifier: "TaskDashboard")
        let taskNavigationController = UINavigationController(rootViewController: taskViewController)
        taskNavigationController.title = "Tasks"
        
        viewControllers = [studyNavigationController, taskNavigationController]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Open the Stop-Signal-Task tab
        selectedIndex = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
    
    
}
