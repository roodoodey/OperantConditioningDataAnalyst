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
#import "MAXRandomUser.h"
#import "MAXOperantCondDataMan.h"
#import "UserDefaults.h"
#import "Constants.h"

@interface UsersOverviewViewModel () {
    NSArray <NSArray <MAXRandomUser *> *> *_userGroups;
    
    MAXOperantCondDataMan *_dataMan;
    
}

@end

@implementation UsersOverviewViewModel

-(id)init {
    if (self = [super init]) {
        
        
        _dataMan = [[MAXOperantCondDataMan alloc] init];
        
        NSArray <MAXRandomUser *> *FIUsers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
        NSArray <MAXRandomUser *> *VIUsers = [_dataMan usersWithReinforcementSchedule: kVISchedule];
        NSArray <MAXRandomUser *> *FRUsers = [_dataMan usersWithReinforcementSchedule: kFRSchedule];
        NSArray <MAXRandomUser *> *VRUsers = [_dataMan usersWithReinforcementSchedule: kVRSchedule];
        
        _userGroups = [NSArray arrayWithObjects: FIUsers, VIUsers, FRUsers, VRUsers, nil];
        
    }
    
    return self;
}


#pragma mark - Getters

-(NSInteger)numberOfSections {
    return 4;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section {
    
    if (_userGroups.count > section) {
        
        NSArray *usersInSection = [_userGroups objectAtIndex: section];
        return usersInSection.count;
        
    }
    
    return 0;
}

-(NSString*)userIdAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self userAtIndexPath:indexPath].objectId;
}

-(MAXRandomUser*)userAtIndexPath:(NSIndexPath*)indexPath {
    MAXRandomUser *randomUser = [[_userGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return randomUser;
}

-(BOOL)isUserExcludedAtIndexPath:(NSIndexPath*)indexPath {
    
    MAXRandomUser *randomUser = [[_userGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSArray *excludedUsers = [UserDefaults excludedUsers];
    
    if ([excludedUsers containsObject:randomUser.objectId]) {
        return YES;
    }
    
    return NO;
}

-(void)excludeOrAddUserDataAtIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(BOOL))block {
    [block copy];
    
    MAXRandomUser *randomUser = [[_userGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([self isUserExcludedAtIndexPath:indexPath]) {

        [UserDefaults removeExcludedUserWithId:randomUser.objectId];
        
        block(NO);
    }
    else {
        
        [UserDefaults exclueUserWithId:randomUser.objectId];
        
        block(YES);
    }
    
}


@end
