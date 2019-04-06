//
//  TabBarViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController, UITabBarControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let summaryViewController = UIStoryboard(name: "HRV", bundle: nil).instantiateViewController(withIdentifier: "HRVViewController") as! SummaryViewController
        let navigationController = UINavigationController(rootViewController: summaryViewController)
        navigationController.title = "Summary"
        
        let taskViewController = UIStoryboard(name: "StopSignalTask", bundle: nil).instantiateViewController(withIdentifier: "UIViewController")
        let navigationController2 = UINavigationController(rootViewController: taskViewController)
        navigationController2.title = "Task"
        viewControllers = [navigationController, navigationController2]
        
//        let tabTwoViewController = UIStoryboard(name: "StopSignalTask", bundle: nil).instantiateViewController(withIdentifier: "StopSignalTaskViewController") as! StopSignalTaskViewController
//
//        let controller = createNavigationController(tabTwoViewController, tabTitle: "Summary")
//
//        viewControllers = [controller, controller]
//
//        print("tab bars: \(toolbarItems?.count)")
//
//        self.toolbarItems?[0].title = "Summry"
//        self.toolbarItems?[1].title = "Task"
    }
    
    
    func createNavigationController(_ viewController: UIViewController, tabTitle: String) -> UINavigationController{
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        return navController
    }
    
    
}
