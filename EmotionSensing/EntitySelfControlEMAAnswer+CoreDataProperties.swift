//
//  EntitySelfControlEMAAnswer+CoreDataProperties.swift
//  EmotionSensing
//
//  Created by Vincent on 4/23/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

import Foundation
import CoreData


extension EntitySelfControlEMAAnswer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntitySelfControlEMAAnswer> {
        return NSFetchRequest<EntitySelfControlEMAAnswer>(entityName: "EntitySelfControlEMAAnswer")
    }

    @NSManaged public var i_have_to_force_myself_to_stay_focused: NSNumber?
    @NSManaged public var i_am_full_of_willpower: NSNumber?
    @NSManaged public var i_am_having_trouble_pulling_myself_together: NSNumber?
    @NSManaged public var i_could_resist_any_temptation: NSNumber?
    @NSManaged public var i_am_having_trouble_paying_attention: NSNumber?
    @NSManaged public var i_have_no_trouble_bringing_myself_to_do_disagreeable_things: NSNumber?
    @NSManaged public var timestamp: NSNumber?
    @NSManaged public var device_id: String?

}
