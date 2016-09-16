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
        
        if (theCol == 0) {
            return @"Avg. Session Length";
        }
        else if(theCol == 1) {
            return @"Std. dev Session Length";
        }
        
    }
    else if(theRow == 1) {
        
        if (theCol == 0) {
            return @"Avg. Session Length";
        }
        else if(theRow == 1) {
            return @"Std. dev Session Length";
        }
        
    }
    else if(theRow == 2) {
        
        if (theCol == 0) {
            return @"Avg. Behavior (30 sec)";
        }
        else if(theCol == 1) {
            return @"Std. dev Behavior (30 sec)";
        }
        
    }
    else if(theRow == 3) {
        
        if (theCol == 0) {
            return @"Avg. Reinforcer (30 sec)";
        }
        else if(theCol == 1) {
            return @"Std. dev Reinforcer (30 sec)";
        }
        
    }
    
    return @"";
}

-(NSString*)dataTitleForRow:(NSInteger)theRow col:(NSInteger)theCol {
    
    if (theRow == 0) {
        
        if (theCol == 0) {
            return [self avgSessionLengthMinutesAndSeconds];
        }
        else if(theCol == 1) {
            return [self stdDevSessionLengthMinutesAndSeconds];
        }
        
    }
    else if(theRow == 1) {
        
        if (theCol == 0) {
            return [self avgSessionLengthSeconds];
        }
        else if(theCol == 1) {
            return [self stdDevSessionLengthSeconds];
        }
        
    }
    else if(theRow == 2) {
        
        if (theCol == 0) {
            
            return [self avgBehavior];
        }
        else if(theCol == 1) {
           
            return [self stdDevBehavior];
        }
    }
    else if(theRow == 3) {
        
        if (theCol == 0) {
            
            return [self avgReinforcer];
        }
        else if(theCol == 1) {
            
            return [self stdDevReinforcer];
        }
        
    }
    
    return @"";
}

-(NSString*)avgBehavior {
    
    return [NSString stringWithFormat:@"%.04f", [_dataMan avgBehaviorForUsers: _randomUsers] * 30.0];
}

-(NSString *)stdDevBehavior {
    
    return [NSString stringWithFormat:@"%.04f", [_dataMan stdDevBehaviorForUsers: _randomUsers] * 30.0];
}

-(NSString*)avgReinforcer {
    
    return [NSString stringWithFormat:@"%.04f", [_dataMan avgReinforcerForUsers: _randomUsers] * 30.0];
    
}

-(NSString *)stdDevReinforcer {
    
    return [NSString stringWithFormat:@"%.04f", [_dataMan stdDevReinforcerForUsers: _randomUsers] * 30.0];
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

-(NSString *)avgSessionLengthSeconds {
    
    return [NSString stringWithFormat:@"%.4f", [_dataMan avgTimeForUsers: _randomUsers]];
}

-(NSString *)stdDevSessionLengthSeconds {
    
    return [NSString stringWithFormat:@"%.4f", [_dataMan stdDevTimeForUsers: _randomUsers]];
}

-(NSString*)avgSessionLengthMinutesAndSeconds {
    
    float avgSessionLength = [_dataMan avgTimeForUsers: _randomUsers];
    
    int minutes = (int)avgSessionLength / 60;
    NSString *minuteString = [NSString stringWithFormat:@"%d", minutes];
    if (minutes < 10) {
        minuteString = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    int seconds = (int)avgSessionLength % 60;
    NSString *secondsString = [NSString stringWithFormat:@"%d", seconds];
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%d", seconds];
    }
    
    
    return [NSString stringWithFormat:@"%@ : %@", minuteString, secondsString];
}

-(NSString *)stdDevSessionLengthMinutesAndSeconds {
    
    float stdDevSessionLength = [_dataMan stdDevTimeForUsers: _randomUsers];
    
    int minutes = (int)stdDevSessionLength / 60;
    NSString *minuteString = [NSString stringWithFormat:@"%d", minutes];
    
    if (minutes < 10) {
        minuteString = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    int seconds = (int)stdDevSessionLength % 60;
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
