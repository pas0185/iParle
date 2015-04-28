//
//  ManagedGroup.h
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ManagedConvo, ManagedGroup;

@interface ManagedGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pfId;
@property (nonatomic, retain) NSString *parentGroupId;

@end

@interface ManagedGroup (CoreDataGeneratedAccessors)

- (void)addSubGroupsObject:(ManagedGroup *)value;
- (void)removeSubGroupsObject:(ManagedGroup *)value;
- (void)addSubGroups:(NSSet *)values;
- (void)removeSubGroups:(NSSet *)values;

- (void)addConvosObject:(ManagedConvo *)value;
- (void)removeConvosObject:(ManagedConvo *)value;
- (void)addConvos:(NSSet *)values;
- (void)removeConvos:(NSSet *)values;

@end
