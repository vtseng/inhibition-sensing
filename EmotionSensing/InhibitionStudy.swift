//
//  InhibitionStudy.swift
//  EmotionSensing
//
//  Created by Vincent on 3/17/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import class Reachability.Reachability
import AWAREFramework

class InhibitionStudy: AWAREStudy{
    
//    var reachability : Reachability
//    var id : Int
    
//    static let shared = InhibitionStudy(input_id: 0)
//        reachability = Reachability()!

//    override func join(withURL url: String!, completion completionHandler: JoinStudyCompletionHandler!) {
//        activateBackgroundSync()
//    }
    
    init(input_id: Int) {
//        super.init()
//        id = input_id
//        reachability = Reachability()!
        
        super.init(reachability: true)
        
    }
    
    
    
    
    func activateBackgroundSync() {
        
//        reachability.whenReachable = { reachability in
//            if reachability.connection == .wifi {
//                print("Reachable via WiFi for inhibition study")
//            } else {
//                print("Reachable via Cellular for inhition study")
//            }
//        }
//        reachability.whenUnreachable = { _ in
//            print("Not reachable for inhibition study")
//        }
//
//        do {
//            try reachability.startNotifier()
//        } catch {
//            print("Unable to start notifier")
//        }
    

    }
    
    func testing() {
        print("testing function")
    }

    deinit{
        print("Object deinit")
    }
    
    @objc func batteryStateDidChange(notification: NSNotification){
        // The stage did change: plugged, unplugged, full charge...
        print("Battery state changed")
    }
    
    @objc func batteryLevelDidChange(notification: NSNotification){
        // The battery's level did change (98%, 99%, ...)
        print("Battery level changed")
    }
}
