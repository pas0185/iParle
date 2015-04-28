//
//  ManagedConvo.h
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//


#import "ProCom-Bridging-Header.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class ManagedBlurb, ManagedGroup;

@interface ManagedConvo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pfId;
@property (nonatomic, retain) NSString * parentGroupId;

@end

@interface ManagedConvo (CoreDataGeneratedAccessors)

- (void)addBlurbsObject:(ManagedBlurb *)value;
- (void)removeBlurbsObject:(ManagedBlurb *)value;
- (void)addBlurbs:(NSSet *)values;
- (void)removeBlurbs:(NSSet *)values;

- (NSString *)getChannelName;

@end
