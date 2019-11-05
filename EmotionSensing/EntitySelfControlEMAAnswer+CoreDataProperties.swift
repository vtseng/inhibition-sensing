//
//  EntitySelfControlEMAAnswer+CoreDataProperties.swift
//  EmotionSensing
//
//  Created by Vincent on 11/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

import Foundation
import CoreData


extension EntitySelfControlEMAAnswer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntitySelfControlEMAAnswer> {
        return NSFetchRequest<EntitySelfControlEMAAnswer>(entityName: "EntitySelfControlEMAAnswer")
    }

    @NSManaged public var i_have_to_force_myself_to_stay_focused: Int16
    @NSManaged public var i_am_full_of_willpower: Int16
    @NSManaged public var i_am_having_trouble_pulling_myself_together: Int16
    @NSManaged public var i_could_resist_any_temptation: Int16
    @NSManaged public var i_am_having_trouble_paying_attention: Int16
    @NSManaged public var i_have_no_trouble_bringing_myself_to_do_disagreeable_things: Int16
    @NSManaged public var timestamp: Int64
    @NSManaged public var device_id: String?

}
