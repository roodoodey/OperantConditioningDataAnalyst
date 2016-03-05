//
//  UserDefaults.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject

+(void)exclueUserWithId:(NSString*)theUserId;
+(void)removeExcludedUserWithId:(NSString*)theUserId;
+(NSArray*)excludedUsers;

@end
