//
//  StopSignalTaskResponse.swift
//  EmotionSensing
//
//  Created by Vincent on 4/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

let SENSOR_STOP_SIGNAL_TASK_RESPONSE = "stop_signal_task_response"

class StopSignalTaskResponse: AWARESensor{
    
    override convenience init() {
        self.init(awareStudy: nil, dbType: AwareDBTypeSQLite)
    }
    
    override convenience init!(awareStudy study: AWAREStudy!) {
        self.init(awareStudy: study, dbType: AwareDBTypeSQLite)
    }
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {
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
        let queryMaker = TCQMaker()
        queryMaker.addColumn("task_status", type: TCQTypeText, default: "''")
        queryMaker.addColumn("task_response_string", type: TCQTypeText, default: "''")
        let query = queryMaker.getTableCreateQuery(withUniques: nil)
        storage.createDBTableOnServer(withQuery: query!, tableName: "stop_signal_task_response")
        
    }
    
}
