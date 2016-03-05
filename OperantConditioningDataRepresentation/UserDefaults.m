//
//  UserDefaults.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

+(void)exclueUserWithId:(NSString *)theUserId {
   
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"excludedUsers"] == nil)  {
        [[NSUserDefaults standardUserDefaults] setValue:[NSArray arrayWithObjects:theUserId, nil] forKey:@"excludedUsers"];
    }
    else {
        NSMutableArray *theExcludedUsers = [NSMutableArray arrayWithArray:(NSArray*)[UserDefaults excludedUsers]];
        [theExcludedUsers addObject:theUserId];
        [[NSUserDefaults standardUserDefaults] setValue:theExcludedUsers forKey:@"excludedUsers"];
    }
}

+(void)removeExcludedUserWithId:(NSString *)theUserId {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"excludedUsers"]) {
        NSMutableArray *theExcludedUser = [NSMutableArray arrayWithArray:[UserDefaults excludedUsers]];
        [theExcludedUser removeObject:theUserId];
        [[NSUserDefaults standardUserDefaults] setValue:(NSArray*)theExcludedUser forKey:@"excludedUsers"];
    }
}

+(NSArray*)excludedUsers {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"excludedUsers"];
}

@end
