//
//  ScoscheHRV.swift
//  EmotionSensing
//
//  Created by Vincent on 2/28/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

class Scosche: AWARESensor {
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {
        let SENSOR_NAME = "ScoscheHRV"

        var storage = AWAREStorage()
        if dbType == AwareDBTypeJSON{
            print("DBTypeJSON is currently not implemented for HRV sensor.")
        }else if dbType == AwareDBTypeCSV{
            print("DBTypeCSV is currently not implemented for HRV sensor.")
        }else{
           
        }
        
        super.init(awareStudy: study, sensorName: SENSOR_NAME, storage: storage)
        
        
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
