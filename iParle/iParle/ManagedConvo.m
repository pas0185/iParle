//
//  ManagedConvo.m
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import "ManagedConvo.h"
#import "ManagedBlurb.h"
#import "ManagedGroup.h"

@implementation ManagedConvo

@dynamic name;
@dynamic pfId;
@dynamic parentGroupId;

- (NSString *)getChannelName
{
    return [NSString stringWithFormat:@"channel%@", self.pfId];
}

@end
