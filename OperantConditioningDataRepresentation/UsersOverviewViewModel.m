//
//  UsersOverviewViewModel.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 04/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UsersOverviewViewModel.h"
#import <Parse/Parse.h>
#import "RandomUser.h"
#import "UserDefaults.h"
#import "Constants.h"

@interface UsersOverviewViewModel () {
    NSMutableArray *userGroups;
    NSArray *allUsers;
}

@end

@implementation UsersOverviewViewModel

-(id)init {
    if (self = [super init]) {
        allUsers = [NSArray array];
        userGroups = [NSMutableArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
    }
    
    return self;
}

-(void)downloadRandomUsersWithBlock:(void (^)(BOOL, NSError *))block {
    [block copy];
    
    __weak typeof (self) wSelf = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"RandomUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (!error) {
                allUsers = users;
                NSLog(@"all users: %d", (int)allUsers.count);
                [wSelf contsructUserGroups:users];
                block(YES, nil);
            }
            else {
                block(NO, error);
            }
            
        });
        
    }];
    
}

#pragma mark - Getters

-(NSInteger)numberOfSections {
    return 4;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (userGroups.count > section) {
        NSMutableArray *usersInSection = [userGroups objectAtIndex:section];
        return usersInSection.count;
    }
    
    return 0;
}

-(NSString*)userIdAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self userAtIndexPath:indexPath].objectId;
}

-(RandomUser*)userAtIndexPath:(NSIndexPath*)indexPath {
    RandomUser *randomUser = [[userGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return randomUser;
}

-(BOOL)isUserExcludedAtIndexPath:(NSIndexPath*)indexPath {
    
    RandomUser *randomUser = [[userGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSArray *excludedUsers = [UserDefaults excludedUsers];
    
    if ([excludedUsers containsObject:randomUser.objectId]) {
        return YES;
    }
    
    return NO;
}

-(void)excludeOrAddUserDataAtIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(BOOL))block {
    [block copy];
    
    RandomUser *randomUser = [[userGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([self isUserExcludedAtIndexPath:indexPath]) {
        NSLog(@"user is excluded");
        [UserDefaults removeExcludedUserWithId:randomUser.objectId];
        
        block(NO);
    }
    else {
        [UserDefaults exclueUserWithId:randomUser.objectId];
        
        block(YES);
    }
    
}

#pragma mark - Data Contrusction

-(void)contsructUserGroups:(NSArray*)theUsers {
    
    NSLog(@"constructing user goups");
    
    NSMutableArray *FI = [NSMutableArray array], *VI = [NSMutableArray array], *FR = [NSMutableArray array], *VR = [NSMutableArray array];
    
    for (RandomUser *randomUser in theUsers) {
        
        if ([randomUser.reinforcementSchedule intValue] == kFISchedule) {
            [FI addObject:randomUser];
        }
        else if([randomUser.reinforcementSchedule intValue] == kVISchedule) {
            [VI addObject:randomUser];
        }
        else if([randomUser.reinforcementSchedule intValue] == kFRSchedule) {
            [FR addObject:randomUser];
        }
        else if([randomUser.reinforcementSchedule intValue] == kVRSchedule) {
            [VR addObject:randomUser];
        }
    }
    
    userGroups = [NSMutableArray arrayWithObjects:FI, VI, FR, VR, nil];
    
}

@end
