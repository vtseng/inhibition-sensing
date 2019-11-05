//
//  EntityStopSignalTask+CoreDataProperties.swift
//  EmotionSensing
//
//  Created by Vincent on 11/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

import Foundation
import CoreData


extension EntityStopSignalTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityStopSignalTask> {
        return NSFetchRequest<EntityStopSignalTask>(entityName: "EntityStopSignalTask")
    }

    @NSManaged public var device_id: String?
    @NSManaged public var timestamp: Int64
    @NSManaged public var task_start_timestamp: Int64
    @NSManaged public var number_total_trials: Int64
    @NSManaged public var number_stop_trials: Int64
    @NSManaged public var trial_id: Int64
    @NSManaged public var stop_signal_delay_milliseconds: Int64
    @NSManaged public var response_type: String?
    @NSManaged public var response_time_milliseconds: Int64
    @NSManaged public var trial_type: String?

}
