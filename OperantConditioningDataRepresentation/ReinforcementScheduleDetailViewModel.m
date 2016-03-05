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

@interface ReinforcementScheduleDetailViewModel () {
    NSArray *_randomUsers;
    NSNumber *_reinforcementSchedule;
    
    NSMutableArray *_behaviorData;
    NSMutableArray *_behaviorChartData;
    
    NSMutableArray *_reinforcerData;
    NSMutableArray *_reinforcerChartData;
}

@end

@implementation ReinforcementScheduleDetailViewModel

-(id)initWithRandomUser:(NSArray *)randomUsers withReinforcementSchedule:(NSNumber *)reinforcementSchedule {
    if (self = [super init]) {
        _randomUsers = randomUsers;
        _randomUsers = [self removeExcludedUSers];
        _reinforcementSchedule = reinforcementSchedule;
        
        _behaviorData = [NSMutableArray array];
        _behaviorChartData = [NSMutableArray array];
        
        _reinforcerData = [NSMutableArray array];
        _reinforcerChartData = [NSMutableArray array];

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
    
    return [NSString stringWithFormat:@"%.02f", [self averageBehaviorWithChartData:_behaviorChartData] * 30];
}

-(NSString*)avgReinforcer {
    
    return [NSString stringWithFormat:@"%.02f", [self averageReinforcerWithChartData:_reinforcerChartData] * 30];
    
}

-(float)averageReinforcerWithChartData:(NSArray*)theChartData {
    
    float numReinforcers = 0;
    
    for (RandomUser *userReinforcement in _randomUsers) {
        numReinforcers += [self reinforcerForUser:userReinforcement chartData:theChartData].count / [userReinforcement.sessionLength floatValue];
    }
    
    return numReinforcers / _randomUsers.count;
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

-(float)averageBehaviorWithChartData:(NSArray*)theChartData {
    
    float numBehaviors = 0;
    
    for (RandomUser *randomUser in _randomUsers) {
        numBehaviors += [self userBehviorForUser:randomUser chartData:theChartData].count / [randomUser.sessionLength floatValue];
    }
    
    
    return numBehaviors / _randomUsers.count;
    
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
    for (RandomUser *user in _randomUsers) {
        NSLog(@"session length is: %@", user.sessionLength);
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
    
    if (theIndex < _behaviorChartData.count) {
        
        float elapsedTimeLast = [[(Behavior*)[(NSArray*)[_behaviorChartData objectAtIndex:theIndex] lastObject] elapsedTime] floatValue];
        
        return ceilf(elapsedTimeLast);
    }
    
    return 0;
}

-(CGFloat)valueForLineAtIndex:(NSUInteger)theLineIndex withHorizontalIndex:(NSUInteger)theHorizontalIndex {
    
    NSArray *lineValues = [_behaviorChartData objectAtIndex:theLineIndex];
    
    int value = 0;
    
    if ([[(Behavior*)[lineValues lastObject] elapsedTime] floatValue] < theHorizontalIndex) {
        return [[NSNumber numberWithFloat:NAN] floatValue];
    }
    
    for (int i = 0; i < lineValues.count; i++) {
        Behavior *behavior = [lineValues objectAtIndex:i];
        NSNumber *elapsedTime = behavior.elapsedTime;
        if ([elapsedTime floatValue] < theHorizontalIndex) {
            value ++;
        }
        
    }
    
    return value;
}


#pragma mark - Download Function

-(void)downloadBehaviorWithLastObjectId:(NSString*)theLastObjectId WithCompletion:(void (^)(BOOL succeeded))block {
    [block copy];
    
    NSArray *theArray = [_randomUsers valueForKey:@"objectId"];
    
    PFQuery *query = [Behavior query];
    [query whereKey:@"userId" containedIn:theArray];
    [query whereKey:@"isCorrectBehavior" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByAscending:@"objectId"];
    [query orderByAscending:@"elapsedTime"];
    
    [query setLimit:1000];
    
    if (theLastObjectId != nil) {
        [query whereKey:@"objectId" greaterThan:theLastObjectId];
    }
    
    __weak typeof (self) wSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *theError) {
        
        [_behaviorData addObjectsFromArray:objects];
        
        if (objects.count == 1000) {
            [wSelf downloadBehaviorWithLastObjectId:[(RandomUser*)[objects lastObject] objectId] WithCompletion:block];
        }
        else {
            [self createBehaviorData];
            block(YES);
        }
        
    }];
    
}

-(void)downloadReinforcersSkipping:(NSInteger)skipAmount withCompletion:(void (^)(NSError *theError))block {
    [block copy];
    
    NSArray *theUsers = [_randomUsers valueForKey:@"objectId"];
    
    PFQuery *query = [Reinforcer query];
    query.limit = 1000;
    query.skip = skipAmount;
    [query whereKey:@"userId" containedIn:theUsers];
    
    __weak typeof (self) wSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *theError) {
        
        [_reinforcerData addObjectsFromArray:objects];
        
        if (theError == nil && objects.count == 1000) {
            
            [wSelf downloadReinforcersSkipping:skipAmount + 1000 withCompletion:block];
            
        }
        else if(theError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createReinforcerData];
               block(nil);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
               block(theError); 
            });
        }
        
    }];
    
}

#pragma mark - Helpers For Chart Data Creation

-(void)createReinforcerData {
    [_reinforcerChartData removeAllObjects];
    
    for (RandomUser *currentUser in _randomUsers) {
        [_reinforcerChartData addObject:[self reinforcerForUser:currentUser]];
    }
    
}

-(NSArray*)reinforcerForUser:(RandomUser*)theRandomUser {
    NSMutableArray *arr = [NSMutableArray array];
    
    for (Reinforcer *currentReinforcer in _reinforcerData) {
        if ([currentReinforcer.userId isEqualToString:theRandomUser.objectId]) {
            [arr addObject:currentReinforcer];
        }
    }
    
    return arr;
}

-(void)createBehaviorData {
    [_behaviorChartData removeAllObjects];
    
    
    for (RandomUser *currentUser in _randomUsers) {
        //[_behaviorChartData addObject:[self behaviorDataForUser:currentUser]];
        NSArray *behaviorsForUser = [self behaviorPerUser:currentUser];
        NSLog(@"behaviors to add: %d", (int)behaviorsForUser.count);
        [_behaviorChartData addObject:behaviorsForUser];
        NSLog(@"num users: %d", (int)_behaviorChartData.count);
    }
    
}

-(NSArray*)behaviorPerUser:(RandomUser*)currentUser {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (Behavior *currentBehavior in _behaviorData) {
        if ([currentBehavior.userId isEqualToString:currentUser.objectId]) {
            [arr addObject:currentBehavior];
        }
    }
    return arr;
}


-(NSArray*)behaviorDataForUser:(RandomUser*)theUser {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (int i = 0; i < 610; i++) {
        int numBehavior = 0;
        
        for (Behavior *currentBehavior in _behaviorData) {
            if ([currentBehavior.elapsedTime floatValue] < i) {
                numBehavior++;
            }
            [tmpArray addObject:[NSNumber numberWithInt:numBehavior]];
        }
        
    }
    
    return tmpArray;
}

@end
