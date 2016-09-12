//
//  ReinforcementScheduleDetailViewModel.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 15/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ReinforcementScheduleDetailViewModel.h"
#import "Behavior.h"
#import "Reinforcer.h"
#import "RandomUser.h"
#import "UserDefaults.h"
#import "Chameleon.h"
#import "Constants.h"

#import "MAXBehavior.h"
#import "MAXReinforcer.h"
#import "MAXRandomUser.h"

@interface ReinforcementScheduleDetailViewModel () {
    
    MAXOperantCondDataMan *_dataMan;
    
    NSArray *_sortDescriptors;
    
    NSArray *_randomUsers;
    NSNumber *_reinforcementSchedule;
    
    NSArray <NSArray <MAXBehavior *> *> *_behaviorData;
    NSArray <NSArray <MAXReinforcer *> *> *_reinforcerData;
    NSMutableArray *_behaviorChartData;
    
}

@end

@implementation ReinforcementScheduleDetailViewModel

-(id)initWithReinforcementSchedule:(NSNumber*)reinforcementSchedule dataMan:(MAXOperantCondDataMan*)theDataMan {
    if (self = [super init]) {
        
        _dataMan = theDataMan;
        
        // sort descriptor to create the bar data
        //NSSortDescriptor *objectIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objectId" ascending:YES];
        NSSortDescriptor *timeElapsedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending:YES];
        _sortDescriptors = @[ timeElapsedDescriptor ];
        
        _randomUsers = [theDataMan usersWithReinforcementSchedule:[reinforcementSchedule intValue]];
        _randomUsers = [self removeExcludedUSers];
        _reinforcementSchedule = reinforcementSchedule;
        
        _behaviorData = [theDataMan behaviorForUsersByUser:_randomUsers];
        _reinforcerData = [theDataMan reinforcerForUsersByUsers: _randomUsers];
        
        NSMutableArray *sortedBehaviorData = [NSMutableArray array];
        for (int i = 0; i < _behaviorData.count; i++) {
            
            NSArray *userBehavior = [_behaviorData objectAtIndex:i];
            userBehavior = [userBehavior sortedArrayUsingDescriptors:_sortDescriptors];
            [sortedBehaviorData addObject:userBehavior];
            
        }
        _behaviorData = sortedBehaviorData;
        
        NSMutableArray *sortedReinforcerData = [NSMutableArray array];
        for (int i = 0; i < _reinforcerData.count; i++) {
            
            NSArray *userReinforcer = [_reinforcerData objectAtIndex: i];
            userReinforcer = [userReinforcer sortedArrayUsingDescriptors: _sortDescriptors];
            [sortedReinforcerData addObject: userReinforcer];
            
        }
        _reinforcerData = sortedReinforcerData;
        
    }
    
    return self;
}

-(NSArray*)removeExcludedUSers {
    NSMutableArray *notExcludedUser = [NSMutableArray arrayWithArray:_randomUsers];
    
    NSLog(@"Users before exclusion: %d", (int)notExcludedUser.count);
    
    NSArray *excludedUsers = [UserDefaults excludedUsers];
    for (RandomUser *randomUser in _randomUsers) {
        
        for (NSString *excludedUserId in excludedUsers) {
            if ([excludedUserId isEqualToString:randomUser.objectId]) {
                [notExcludedUser removeObject:randomUser];
            }
        }
    }
    
    NSLog(@"users after exclusion: %d", (int)notExcludedUser.count);
    
    return notExcludedUser;
}


#pragma mark - Getters And Setters

-(NSString*)reinforcementTitleForNum:(NSNumber *)reinforcementNum {
    if ([reinforcementNum intValue] == kFISchedule) {
        return @"Fixed Interval";
    }
    else if([reinforcementNum intValue] == kVISchedule) {
        return @"Variable Interval";
    }
    else if([reinforcementNum intValue] == kFRSchedule) {
        return @"Fixed Ratio";
    }
    else if([reinforcementNum intValue] == kVRSchedule) {
        return @"Variable Ratio";
    }
    else {
        return @"Unknown";
    }
}

-(NSUInteger)numReinforcersForLineAtIndex:(NSInteger)theIndex {
    
    return _reinforcerData.count;
}

// MARK: Block Data

-(NSString*)titleForRow:(NSInteger)theRow col:(NSInteger)theCol {
    if (theRow == 0) {
        return @"Avg. Session Length";
    }
    else if(theRow == 1) {
        if (theCol == 0) {
            return @"Avg. Behavior (30 sec)";
        }
        else if(theCol == 1) {
            return @"Avg. Reinforcer (30 sec)";
        }
    }
    
    return @"";
}

-(NSString*)dataTitleForRow:(NSInteger)theRow col:(NSInteger)theCol {
    
    if (theRow == 0) {
        return [self avgSessionLength];
    }
    else if(theRow == 1) {
        
        if (theCol == 0) {
            
            return [self avgBehavior];
        }
        else if(theCol == 1) {
           
            return [self avgReinforcer];
        }
    }
    
    return @"";
}

-(NSString*)avgBehavior {
    
    return [NSString stringWithFormat:@"%.02f", [_dataMan avgBehaviorForUsers:_randomUsers] * 30.0];
}

-(NSString*)avgReinforcer {
    
    return [NSString stringWithFormat:@"%.02f", [_dataMan avgReinforcerForUsers:_randomUsers] * 30.0];
    
}

-(NSArray*)reinforcerForUser:(RandomUser*)theRandomUser chartData:(NSArray*)theChartData {
    
    for (NSArray *reinforcers in theChartData) {
        Reinforcer *firstReinf = [reinforcers firstObject];
        
        if ([firstReinf.userId isEqualToString:theRandomUser.objectId]) {
            return reinforcers;
        }
    }
    
    return nil;
}


-(NSArray*)userBehviorForUser:(RandomUser*)theRandomUser chartData:(NSArray*)theChartData {
    
    for (NSArray *userBehavior in theChartData) {
        Behavior *firstBehav = [userBehavior firstObject];
        
        if ([firstBehav.userId isEqualToString:theRandomUser.objectId]) {
            return userBehavior;
        }
        
    }
    
    return nil;
}

-(NSString*)avgSessionLength {
    
    float sessionLength = 0;
    
    for (MAXRandomUser *user in _randomUsers) {
        sessionLength += [user.sessionLength floatValue];
    }
    
    sessionLength /= (float)_randomUsers.count;
    
    int minutes = (int)sessionLength / 60;
    NSString *minuteString = [NSString stringWithFormat:@"%d", minutes];
    if (minutes < 10) {
        minuteString = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    int seconds = (int)sessionLength % 60;
    NSString *secondsString = [NSString stringWithFormat:@"%d", seconds];
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%d", seconds];
    }
    
    
    return [NSString stringWithFormat:@"%@ : %@", minuteString, secondsString];
}

// MARK: Chart Data

-(CGFloat)maxYValue {
    return 1100;
}

-(NSString*)maxXValueString {
    return [NSString stringWithFormat:@"%d", 610];
}

-(NSString*)maxYValueString {
    return [NSString stringWithFormat:@"%d", 1100];
}

-(NSUInteger)numLines {
    return _randomUsers.count;
}

-(UIColor*)colorForLineAtIndex:(NSInteger)theIndex {
    
    if (theIndex == 0) {
        return [UIColor flatBlueColor];
    }
    else if(theIndex == 1) {
        return [UIColor flatYellowColor];
    }
    else if(theIndex == 2) {
        return [UIColor flatRedColor];
    }
    else if(theIndex == 3) {
        return [UIColor flatPinkColor];
    }
    else if(theIndex == 4) {
        return [UIColor flatLimeColor];
    }
    else if(theIndex == 5) {
        return [UIColor flatWatermelonColorDark];
    }
    else if(theIndex == 6) {
        return [UIColor flatPurpleColor];
    }
    else if(theIndex == 7) {
        return [UIColor flatBrownColor];
    }
    
    return [UIColor flatMintColor];
    
}

-(NSUInteger)numValuesForLineAtIndex:(NSUInteger)theIndex {
    
    return 610;
    
}

-(CGFloat)valueForLineAtIndex:(NSUInteger)theLineIndex withHorizontalIndex:(NSUInteger)theHorizontalIndex {
    
    NSArray *lineValues = [_behaviorData objectAtIndex:theLineIndex];
    
    int value = 0;
    
    if ([[(MAXBehavior*)[lineValues lastObject] elapsedTime] floatValue] < theHorizontalIndex) {
        return [[NSNumber numberWithFloat:NAN] floatValue];
    }
    
    for (int i = 0; i < lineValues.count; i++) {
        MAXBehavior *behavior = [lineValues objectAtIndex:i];
        NSNumber *elapsedTime = behavior.elapsedTime;
        if ([elapsedTime floatValue] < theHorizontalIndex) {
            value ++;
        }
        
    }
    
    return value;
}


@end
