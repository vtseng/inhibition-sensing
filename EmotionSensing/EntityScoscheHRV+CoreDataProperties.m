//
//  EntityScoscheHRV+CoreDataProperties.m
//  EmotionSensing
//
//  Created by Vincent on 3/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

#import "EntityScoscheHRV+CoreDataProperties.h"

@implementation EntityScoscheHRV (CoreDataProperties)

+ (NSFetchRequest<EntityScoscheHRV *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EntityScoscheHRV"];
}

@dynamic timestamp;
@dynamic rr_interval;
@dynamic device_id;

@end
