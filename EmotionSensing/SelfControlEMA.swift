//
//  SelfControlEMAResponse.swift
//  EmotionSensing
//
//  Created by Vincent on 4/23/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

let SENSOR_SELF_CONTROL_EMA_ANSWER = "plugin_self_control_ema_answer"

class SelfControlEMA: AWARESensor{
    
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
            storage = SQLiteStorage(study: study, sensorName: SENSOR_SELF_CONTROL_EMA_ANSWER, entityName: String(describing: EntitySelfControlEMAAnswer.self), insertCallBack: { (dataDict, childContext, entity) in
                
            })
        default:
            print("\(dbType) is not yet implemented")
        }
        
        super.init(awareStudy: study, sensorName: SENSOR_SELF_CONTROL_EMA_ANSWER, storage: storage)
    }
    
    
    override func createTable() {
        if isDebug(){
            print("\(String(describing: self.getName())) Create Table")
        }
        let queryMaker = TCQMaker()
        queryMaker.addColumn(KEY_QUESTION_FORCE_TO_STAY_FOCUSED, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_QUESTION_FULL_OF_WILLPOWER, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_QUESTION_PULLING_MYSELF_TOGETHER, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_QUESTION_RESIST_TEMPTATION, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_QUESTION_TROUBLE_PAYING_ATTENTION, type: TCQTypeInteger, default: "-1")
        queryMaker.addColumn(KEY_QUESTION_NO_TROUBLE_WITH_DISAGREEABLE_THINGS, type: TCQTypeInteger, default: "-1")
        
        storage!.createDBTableOnServer(with: queryMaker)
    }
}
