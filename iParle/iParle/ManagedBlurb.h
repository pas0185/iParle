//
//  ManagedBlurb.h
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSQMessageData.h"

@class ManagedConvo;

@interface ManagedBlurb : NSManagedObject<JSQMessageData>

@property (nonatomic, retain) NSString * convoId;
@property (nonatomic, retain) NSString * pfId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSDate * createdAt;
//@property (nonatomic, retain) NSString * profilePic;

- (NSString *) userPic;

@end
