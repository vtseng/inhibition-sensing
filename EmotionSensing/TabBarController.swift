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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let summaryViewController = UIStoryboard(name: "HRV", bundle: nil).instantiateViewController(withIdentifier: "HRVViewController") as! SummaryViewController
        let summaryNavigationController = UINavigationController(rootViewController: summaryViewController)
        summaryNavigationController.title = "Summary"
        
//        let taskViewController = UIStoryboard(name: "StopSignalTask", bundle: nil).instantiateViewController(withIdentifier: "StopSignalTask")
        let taskViewController = UIStoryboard(name: "TaskDashboard", bundle: nil).instantiateViewController(withIdentifier: "TaskDashboard")
        let taskNavigationController = UINavigationController(rootViewController: taskViewController)
        taskNavigationController.title = "Task"
        
        viewControllers = [summaryNavigationController, taskNavigationController]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Open the Stop-Signal-Task tab
        selectedIndex = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    
}
