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
    
    override init() {
        super.init()
    }
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {
        super.init(awareStudy: study, dbType: dbType)
    }
    
    
    override func createTable() {
        if self.isDebug(){
            print("\(String(describing: self.getName())) Create Table")
        }
        let queryMaker = TCQMaker()
        queryMaker.addColumn("timestamp", type: TCQTypeReal, default: "0")
        queryMaker.addColumn("rr_interval", type: TCQTypeReal, default: "0")
        self.storage.createDBTableOnServer(with: queryMaker)
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
