//
//  EntityScoscheHRV+CoreDataProperties.h
//  EmotionSensing
//
//  Created by Vincent on 3/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//
//

#import "EntityScoscheHRV+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EntityScoscheHRV (CoreDataProperties)

+ (NSFetchRequest<EntityScoscheHRV *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *timestamp;
@property (nullable, nonatomic, copy) NSNumber *rr_interval;
@property (nullable, nonatomic, copy) NSString *device_id;

@end

NS_ASSUME_NONNULL_END
