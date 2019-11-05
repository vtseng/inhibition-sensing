//
//  StopSignalTaskResponse.swift
//  EmotionSensing
//
//  Created by Vincent on 4/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

let SENSOR_STOP_SIGNAL_TASK_RESPONSE = "plugin_stop_signal_task_response"

class StopSignalTaskResponse: AWARESensor{
    
    override convenience init() {
        self.init(awareStudy: nil, dbType: AwareDBTypeSQLite)
    }
    
    override convenience init(awareStudy study: AWAREStudy!) {
        self.init(awareStudy: study, dbType: AwareDBTypeSQLite)
    }
    
    override init(awareStudy study: AWAREStudy!, dbType: AwareDBType) {
        var storage = AWAREStorage()
        switch dbType {
        case AwareDBTypeSQLite:
            storage = SQLiteStorage(study: study, sensorName: SENSOR_STOP_SIGNAL_TASK_RESPONSE, entityName: String(describing: EntityStopSignalTask.self), insertCallBack: { (dataDict, childContext, entity) in
                
            })
        default:
            print("\(dbType) is not yet implemented")
        }
        
        super.init(awareStudy: study, sensorName: SENSOR_STOP_SIGNAL_TASK_RESPONSE, storage: storage)
    }
    
    
    override func createTable() {
        if isDebug(){
            print("\(String(describing: self.getName())) Create Table")
        }
        let queryMaker = TCQMaker()
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_NUMBER_STOP_TRIALS, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_NUMBER_TOTAL_TRIALS, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TRIAL_ID, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_RESPONSE_TIME, type: TCQTypeReal, default: "-1.0")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_STOP_SIGNAL_DELAY, type: TCQTypeReal, default: "-1.0")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_START_TIMESTAMP, type: TCQTypeReal, default: "-1.0")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_RESPONSE_TYPE, type: TCQTypeText, default: "''")
        queryMaker.addColumn(KEY_STOP_SIGNAL_TASK_TRIAL_TYPE, type: TCQTypeText, default: "''")
        
        storage!.createDBTableOnServer(with: queryMaker)
    }
    
}
