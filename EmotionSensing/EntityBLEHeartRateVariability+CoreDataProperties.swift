//
//  EntityBLEHeartRateVariability+CoreDataProperties.swift
//  EmotionSensing
//
//  Created by Vincent on 4/17/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

import Foundation
import CoreData


extension EntityBLEHeartRateVariability {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityBLEHeartRateVariability> {
        return NSFetchRequest<EntityBLEHeartRateVariability>(entityName: "EntityBLEHeartRateVariability")
    }

    @NSManaged public var body_location: NSNumber?
    @NSManaged public var heart_rate: NSNumber?
    @NSManaged public var rr_interval: NSNumber?
    @NSManaged public var rssi: NSNumber?
    @NSManaged public var timestamp: NSNumber?
    @NSManaged public var device_id: String?
    @NSManaged public var manufacturer: String?
    @NSManaged public var battery_level: NSNumber?
    @NSManaged public var peripheral_id: String?

}
