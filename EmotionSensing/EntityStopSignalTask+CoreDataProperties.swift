//
//  EntityStopSignalTask+CoreDataProperties.swift
//  EmotionSensing
//
//  Created by Vincent on 4/5/19.
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
    @NSManaged public var timestamp: NSNumber?
    @NSManaged public var task_status: String?
    @NSManaged public var task_response_string: String?

}
