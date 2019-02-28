//
//  ScoscheHRV.swift
//  EmotionSensing
//
//  Created by Vincent on 2/28/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

class ScoscheHRV: AWARESensor {
    
    override init!(dbType: AwareDBType) {
        super.init(dbType: dbType)
    }
    
    override func createTable() {
        super.createTable()
    }
    
    
    override func startSensor() -> Bool {
        return super.startSensor()
    }
    
    
    override func stopSensor() -> Bool {
        return super.stopSensor()
    }
    
    
    override func startSyncDB() {
        super.startSyncDB()
    }
    
    
    override func stopSyncDB() {
        super.stopSyncDB()
    }
}
