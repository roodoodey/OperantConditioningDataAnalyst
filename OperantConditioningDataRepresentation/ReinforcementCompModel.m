//
//  ReinforcementCompModel.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 10/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "ReinforcementCompModel.h"
#import "RandomUser.h"
#import "Behavior.h"
#import "Reinforcer.h"
#import "Constants.h"
#import "Chameleon.h"
#import "Constants.h"
#import "UserDefaults.h"

#import "MAXBehavior.h"
#import "MAXReinforcer.h"
#import "MAXRandomUser.h"


@interface ReinforcementCompModel () {
    
    MAXOperantCondDataMan *_dataMan;
    
    NSArray *_users;
    
    NSArray *_FIUsers;
    NSArray *_VIUsers;
    NSArray *_FRUsers;
    NSArray *_VRUsers;
    
    NSArray *_behaviorData;
    NSMutableArray *_behaviorChartData;
    
    NSMutableArray *_reinforcerData;
    NSMutableArray *_reinforcerChartData;
}

@end

@implementation ReinforcementCompModel

-(id)initWithUsers:(NSArray *)theUsers dataMan:(MAXOperantCondDataMan *)theDataMan {
    if (self = [super init]) {
        
        _dataMan = theDataMan;
        
        _users = theUsers;
        _users = [self removeExcludedUSers];
        
        NSSortDescriptor *elapsedTimeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending:YES];
        
        _FIUsers = [theDataMan usersWithReinforcementSchedule:kFISchedule];
        _VIUsers = [theDataMan usersWithReinforcementSchedule:kVISchedule];
        _FRUsers = [theDataMan usersWithReinforcementSchedule:kFRSchedule];
        _VRUsers = [theDataMan usersWithReinforcementSchedule:kVRSchedule];
        
        NSArray *FIBehavior = [[theDataMan behaviorOnlyForUsers:_FIUsers] sortedArrayUsingDescriptors:@[elapsedTimeSortDescriptor]];
        NSArray *VIBehavior = [[theDataMan behaviorOnlyForUsers:_VIUsers] sortedArrayUsingDescriptors:@[elapsedTimeSortDescriptor]];
        NSArray *FRBehavior = [[theDataMan behaviorOnlyForUsers:_FRUsers] sortedArrayUsingDescriptors:@[elapsedTimeSortDescriptor]];
        NSArray *VRBehavior = [[theDataMan behaviorOnlyForUsers:_VRUsers] sortedArrayUsingDescriptors:@[elapsedTimeSortDescriptor]];
        NSLog(@"FI behavior is: %@", FIBehavior);
        _behaviorData = @[FIBehavior, VIBehavior, FRBehavior, VRBehavior];
        

        CGFloat verticalValueOne = [self verticalValueForHorizontalIndex:100 forLineIndex:1];
        CGFloat verticalValueTwo = [self verticalValueForHorizontalIndex:120 forLineIndex:1];
        CGFloat verticalValue200 = [self verticalValueForHorizontalIndex:200 forLineIndex:1];
        
        CGFloat verticalValueThree = [self verticalValueForHorizontalIndex:500 forLineIndex:1];
        CGFloat verticalValueFour = [self verticalValueForHorizontalIndex:600 forLineIndex:1];
        
        NSLog(@"from 100 to 200: %f from 500 to 600: %f", verticalValue200 - verticalValueOne, verticalValueFour - verticalValueThree);
        
    }
    
    return self;
}

-(NSArray*)removeExcludedUSers {
    NSMutableArray *notExcludedUser = [NSMutableArray arrayWithArray:_users];
    
    NSLog(@"Users before exclusion: %d", (int)notExcludedUser.count);
    
    NSArray *excludedUsers = [UserDefaults excludedUsers];
    for (RandomUser *randomUser in _users) {
        
        for (NSString *excludedUserId in excludedUsers) {
            if ([excludedUserId isEqualToString:randomUser.objectId]) {
                [notExcludedUser removeObject:randomUser];
            }
        }
    }
    
    NSLog(@"users after exclusion: %d", (int)notExcludedUser.count);
    
    return notExcludedUser;
}


#pragma mark - Block 

-(NSString*)stringTitleForRow:(NSUInteger)theRow col:(NSUInteger)theCol {
    
    if (theRow == 0) {
        return @"Fixed Interval";
    }
    else if(theRow == 4) {
        return @"Variable Interval";
    }
    else if(theRow == 8) {
        return @"Fixed Ratio";
    }
    else if(theRow == 12) {
        return @"Variable Ratio";
    }
    
    int remainder = theRow % 4;
    
    if (remainder == 1) {
        if (theCol == 0) {
            return @"Avg. Time (30 sec)";
        }
        else if(theCol == 1) {
            return @"Std. Time (30 sec)";
        }
    }
    
    if (remainder == 2) {
        if (theCol == 0) {
            return @"Avg. Behavior (30 sec)";
        }
        else if(theCol == 1) {
            return @"Std. Behavior (30 sec)";
        }
    }
    
    if (remainder == 3) {
        if (theCol == 0) {
            return @"Avg. Reinforcer (30 sec)";
        }
        else if(theCol == 1) {
            return @"Std. Reinforcer (30 sec)";
        }
    }
    
    return @"";
}

-(NSString*)stringForRow:(NSUInteger)theRow col:(NSUInteger)theCol {
    
    if (theRow == 1 || theRow == 2 || theRow == 3) {
        
        ////// FI Schedule
        
        if (theRow == 2 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgBehaviorForUsers:_FIUsers] * 30.0];
        }
        else if(theRow == 2 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevBehaviorForUsers:_FIUsers]];
        }
        else if(theRow == 3 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgReinforcerForUsers:_FIUsers] * 30.0];
        }
        else if(theRow == 3 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevReinforcerForUsers:_FIUsers]];
        }
        else if(theRow == 1 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgTimeForUsers:_FIUsers]];
        }
        else if(theRow == 1 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevTimeForUsers:_FIUsers]];
        }
        
    }
    else if(theRow >= 5 && theRow <= 7) {
        
        // VI Schedule
        
        if (theRow == 6 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgBehaviorForUsers:_VIUsers] * 30.0];
        }
        else if(theRow == 6 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevBehaviorForUsers:_VIUsers]];
        }
        else if(theRow == 7 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgReinforcerForUsers:_VIUsers] * 30.0];
        }
        else if(theRow == 7 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevReinforcerForUsers:_VIUsers]];
        }
        else if(theRow == 5 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgTimeForUsers:_VIUsers]];
        }
        else if(theRow == 5 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevTimeForUsers:_VIUsers]];
        }
        
        
    }
    else if(theRow >= 9 && theRow <= 11) {
        
        // FR Schedule
        
        if (theRow == 10 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgBehaviorForUsers:_FRUsers] * 30.0];
        }
        else if(theRow == 10 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevBehaviorForUsers:_FRUsers]];
        }
        else if(theRow == 11 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgReinforcerForUsers:_FRUsers] * 30.0];
        }
        else if(theRow == 11 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevReinforcerForUsers:_FRUsers]];
        }
        else if(theRow == 9 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgTimeForUsers:_FRUsers]];
        }
        else if(theRow == 9 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevTimeForUsers:_FRUsers]];
        }
        
    }
    else if(theRow >= 13 && theRow <= 15) {
        
        // FR Schedule
        
        if (theRow == 14 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgBehaviorForUsers:_VRUsers] * 30.0];
        }
        else if(theRow == 14 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevBehaviorForUsers:_VRUsers]];
        }
        else if(theRow == 15 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgReinforcerForUsers:_VRUsers] * 30.0];
        }
        else if(theRow == 15 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevReinforcerForUsers:_VRUsers]];
        }
        else if(theRow == 13 && theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan avgTimeForUsers:_VRUsers]];
        }
        else if(theRow == 13 && theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevTimeForUsers:_VRUsers]];
        }
        
    }
    
    return @"";
}


-(NSArray*)usersForSchedule:(NSUInteger)theScheduleType {
    NSMutableArray *usersForSched = [NSMutableArray array];
    
    for (RandomUser *user in _users) {
        if ([user.reinforcementSchedule intValue] == theScheduleType) {
            [usersForSched addObject:user];
        }
    }
    
    return usersForSched;
}

-(NSArray*)behaviorForUser:(RandomUser*)theRandomUser chartData:(NSArray*)theChartData {
    for (NSArray *userBehavior in theChartData) {
        Behavior *firstBehav = [userBehavior firstObject];
        
        if ([firstBehav.userId isEqualToString:theRandomUser.objectId]) {
            return userBehavior;
        }
        
    }
    
    return nil;
}

-(NSArray*)reinforcerForUser:(RandomUser*)theRandomUser chartData:(NSArray*)theChartData {
    for (NSArray *userReinforcer in theChartData) {
        
        Reinforcer *firstReinf = [userReinforcer firstObject];
        
        if ([firstReinf.userId isEqualToString:theRandomUser.objectId]) {
            return userReinforcer;
        }
        
    }
    
    return nil;
}


#pragma mark - Chart

-(NSInteger)numLines {
    return _behaviorData.count;
}

-(NSUInteger)numVerticalValuesForLine:(NSUInteger)theLineIndex {
    
    return 600;
    /*
    if (theLineIndex < _behaviorData.count) {
        NSArray *scheduleData = [_behaviorData objectAtIndex:theLineIndex];
        MAXBehavior *behavior = [scheduleData lastObject];
        //float elapsedTimeLast = [[(MAXBehavior*)[(NSArray*)[_behaviorData objectAtIndex:theLineIndex] lastObject] elapsedTime] floatValue];
        
        return ceilf([behavior.elapsedTime floatValue]);
        
    }
    */
    return 0;
}

-(CGFloat)verticalValueForHorizontalIndex:(NSUInteger)theHorizIndex forLineIndex:(NSUInteger)theLindeIndex {
    
    NSArray *lineValues = [_behaviorData objectAtIndex:theLindeIndex];
    
    float value = 0;
    
    for (int i = 0; i < lineValues.count; i++) {
        MAXBehavior *behavior = [lineValues objectAtIndex:i];
       
        if ([behavior.elapsedTime floatValue] < theHorizIndex ) {
            value++;
        }
    }
    
    //value /= (float)[self numVerticalValuesForLine:theLindeIndex];
    //return value;
    return value / [self numUsersForLineIndex:theLindeIndex];
}

-(UIColor*)colorForLineAtIndex:(NSUInteger)theLineIndex {
    if (theLineIndex == 0) {
        return [UIColor flatBlueColor];
    }
    else if(theLineIndex == 1) {
        return [UIColor flatRedColor];
    }
    else if(theLineIndex == 2) {
        return [UIColor flatYellowColor];
    }
    else if(theLineIndex == 3) {
        return [UIColor flatGreenColor];
    }
    
    return [UIColor flatPinkColor];
}

-(int)numUsersForLineIndex:(int)theLineIndex {
    
    int numUsers = 0;
    
    for (RandomUser *user in _users) {
        if (theLineIndex == 0  && [user.reinforcementSchedule intValue] == kFISchedule) {
            numUsers++;
        }
        else if(theLineIndex == 1 && [user.reinforcementSchedule intValue] == kVISchedule) {
            numUsers++;
        }
        else if(theLineIndex == 2 && [user.reinforcementSchedule intValue] == kFRSchedule) {
            numUsers++;
        }
        else if(theLineIndex == 3 && [user.reinforcementSchedule intValue] == kVRSchedule) {
            numUsers++;
        }
    }
    
    
    return numUsers;
}


@end
