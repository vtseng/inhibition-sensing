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
        
        let tabOneViewController: SummaryViewController = UIStoryboard(name: "HRV", bundle: nil).instantiateViewController(withIdentifier: "HRVViewController") as! SummaryViewController
        
        
        self.viewControllers = [tabOneViewController, tabOneViewController]
        
    }
    
    
}
