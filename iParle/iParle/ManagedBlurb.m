//
//  ManagedBlurb.m
//  ProCom
//
//  Created by Patrick Sheehan on 4/9/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

#import "ManagedBlurb.h"
#import "ManagedConvo.h"


@implementation ManagedBlurb

@dynamic convoId;
@dynamic pfId;
@dynamic text;
@dynamic createdAt;
@dynamic userId;
@dynamic username;
//@dynamic profilePic;

#pragma mark - JSQMessageData Methods

- (NSDate *)date {
    return self.createdAt;
}

- (NSString *)senderId {
    return self.userId;
}

#pragma mark - Helper Methods

- (NSString *)senderDisplayName {
    return self.username;
}

- (NSUInteger)messageHash {
    return self.text.hash;
}

- (NSString *) userPic {
    
    PFQuery* query = [PFUser query];
    [query whereKey:@"objectId" equalTo:self.userId];

    // FIXME later
    // This asynchronous call is BAD vv
    NSArray* results = [query findObjects];
    // ^^ Queries network for every single blurb e'rytime, but it works for now
    
    if (results.count > 0) {
        PFUser *user = [results firstObject];
        NSString *profilePicURL = user[@"profilePicture"];
        return profilePicURL;
    }
    
    return nil;
}

- (BOOL)isMediaMessage {
    return false;
}

@end
