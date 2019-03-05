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
    
    override convenience init() {
        self.init(awareStudy: nil, dbType: AwareDBTypeSQLite)
    }
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {

        let SENSOR_NAME = "ScoscheHRV"
        let KEY_SCOSCHE_HRV_TIMESTAMP = "timestamp"
        let KEY_SCOSCHE_HRV_RR_INTERVAL = "rr_interval"

        var storage = AWAREStorage()
        if dbType == AwareDBTypeJSON{
            print("DBTypeJSON is currently not implemented for HRV sensor.")
        }else if dbType == AwareDBTypeCSV{
            print("DBTypeCSV is currently not implemented for HRV sensor.")
        }else{
//            storage = SQLiteStorage(study: study, sensorName: SENSOR_NAME, entityName: String(describing: EntityScoscheHRV.self), insertCallBack: { (dataDict, childContext, entity) in
//                let entityHRV = NSEntityDescription.insertNewObject(forEntityName: entity!, into: childContext!) as! EntityScoscheHRV
//                entityHRV.timestamp = dataDict?[KEY_SCOSCHE_HRV_TIMESTAMP] as! Double
//                entityHRV.rr_interval = dataDict?[KEY_SCOSCHE_HRV_RR_INTERVAL] as! Double
//
//            })
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
