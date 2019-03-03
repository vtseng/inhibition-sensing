//
//  EntityScoscheHRV+CoreDataProperties.swift
//  EmotionSensing
//
//  Created by Vincent on 3/3/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

import Foundation
import CoreData


extension EntityScoscheHRV {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityScoscheHRV> {
        return NSFetchRequest<EntityScoscheHRV>(entityName: "EntityScoscheHRV")
    }

    @NSManaged public var timestamp: Double
    @NSManaged public var rr_interval: Double

}
