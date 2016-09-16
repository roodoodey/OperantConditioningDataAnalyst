//
//  UserDetailViewModel.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UserDetailViewModel.h"
#import "MAXReinforcer.h"
#import "MAXBehavior.h"
#import "MAXRandomUser.h"
#import "UserDefaults.h"
#import "Constants.h"

#import "MAXOperantCondDataMan.h"

@interface UserDetailViewModel () {
    
    MAXOperantCondDataMan *_dataMan;
    
    MAXRandomUser *_randomUser;
    
    NSArray <MAXBehavior *> *_behaviorArray;
    NSArray <MAXReinforcer *> *_reinforcerArray;
    NSArray <NSNumber *> *_behaviorChartData;
    NSArray <NSNumber *> *_reinforcerChartData;
}

@end

const int maxTimePlayed = 610;

@implementation UserDetailViewModel

-(id)initWithUser:(MAXRandomUser *)theRandomUser {
    
    if (self = [super init]) {
        
        _randomUser = theRandomUser;
        _behaviorArray = [NSMutableArray array];
        _behaviorChartData = [NSMutableArray array];
        _reinforcerArray = [NSArray array];
        
        _dataMan = [[MAXOperantCondDataMan alloc] init];
        
        _behaviorArray = [_dataMan behaviorOnlyForUsers: @[theRandomUser] ];
        _behaviorArray = [_behaviorArray sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending: YES]]];
        _behaviorChartData = [self constructDataWithBehaviorArray: _behaviorArray];
        
        _reinforcerArray = [_dataMan reinforcerOnlyForUsers: @[theRandomUser]];
        _reinforcerArray = [_reinforcerArray sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending: YES]]];
        _reinforcerChartData = [self constructDataWithReinforcerArray: _reinforcerArray];
        
    }
    
    return self;
}

#pragma mark - Getter methods

-(NSString*)userId {
    return _randomUser.objectId;
}

-(NSString*)sessionLength {
    
    NSLog(@"session length is: %d", [_randomUser.sessionLength intValue]);
    
    NSString *seconds;
    NSString *minutes;
    
    if ([self sessionLengthSeconds] < 10) {
        seconds = [NSString stringWithFormat:@"0%d", (int)[self sessionLengthSeconds]];
    }
    else {
        seconds = [NSString stringWithFormat:@"%d", (int)[self sessionLengthSeconds]];
    }
    
    if ([self sessionLenghtMinutes] < 10) {
        minutes = [NSString stringWithFormat:@"0%d", (int)[self sessionLenghtMinutes]];
    }
    else {
        minutes = [NSString stringWithFormat:@"%d", (int)[self sessionLenghtMinutes]];
    }
    
    
    return [NSString stringWithFormat:@"%@ : %@", minutes, seconds];
}

-(NSString*)avgBehavior {

    return [NSString stringWithFormat:@"%.02f", [_dataMan avgBehaviorForUsers: @[_randomUser]] * 30.0];
}

-(NSString*)stdDevBehavior {
    return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevBehaviorForUsers: @[_randomUser]] * 30.0];
}

-(NSString*)avgReinforcer {
    return [NSString stringWithFormat:@"%.02f", [_dataMan avgReinforcerForUsers: @[_randomUser]] * 30.0];
}

-(NSString*)stdDevReinforcer {
    return [NSString stringWithFormat:@"%.02f", [_dataMan stdDevReinforcerForUsers: @[_randomUser]] * 30.0];
}

-(NSString *)userGender {
    if ([_randomUser.gender intValue] == kMale) {
        return @"Male";
    }
    else if([_randomUser.gender intValue] == kFemale) {
        return @"Female";
    }
    
    return @"";
}

-(NSString *)userPlayFreq {
    
    if ([_randomUser.playingFrequency intValue] == kFirstFreq) {
        return @"< 2";
    }
    else if([_randomUser.playingFrequency intValue] == kSecondFreq) {
        return @"2-3";
    }
    else if([_randomUser.playingFrequency intValue] == kThirdFreq) {
        return @"4-5";
    }
    else if([_randomUser.playingFrequency intValue] == kFourthFreq) {
        return @"6-7";
    }
    else if([_randomUser.playingFrequency intValue] == kFifthFreq) {
        return @"> 8";
    }
    
    return @"";
}

-(NSString *)userPlayAmount {
    
    if ([_randomUser.playingAmount intValue] == kFirstAmount) {
        return @"< 1";
    }
    else if([_randomUser.playingAmount intValue] == kSecondAmount) {
        return @"2-3";
    }
    else if([_randomUser.playingAmount intValue] == kThirdAmount) {
        return @"4-5";
    }
    else if([_randomUser.playingAmount intValue] == kFourthAmount) {
        return @"6-7";
    }
    else if([_randomUser.playingAmount intValue] == kFifthAmount) {
        return @"> 8";
    }
    
    return @"";
}

-(NSString*)maxXValue {
    
    return [NSString stringWithFormat:@"%d", 600];
}

-(NSString*)maxYValue {
    
    return [NSString stringWithFormat:@"%.0f", [self highestYValue]];
}

-(NSString *)totalBehaviorForUser {
    
    return [NSString stringWithFormat:@"%lu", _behaviorArray.count];
}

-(NSString *)totalReinforcersForUsers {
    
    return [NSString stringWithFormat:@"%lu", _behaviorArray.count];
}

-(BOOL)sessionLengthIncorrect {
    if ([_randomUser.sessionLength floatValue] < 120 || [_randomUser.sessionLength floatValue] > 660) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isExcluded {
    for (NSString *currentUserId in [UserDefaults excludedUsers]) {
        if ([currentUserId isEqualToString:_randomUser.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)includeOrExcludeData {
    if ([self isExcluded]) {
        [UserDefaults removeExcludedUserWithId:_randomUser.objectId];
    }
    else {
        [UserDefaults exclueUserWithId:_randomUser.objectId];
    }
}

#pragma mark - Data Manipulation

-(NSInteger)sessionLenghtMinutes {
    int minutes = [_randomUser.sessionLength intValue] / 60;

    return minutes;
}

-(NSInteger)sessionLengthSeconds {
    int seconds = [_randomUser.sessionLength intValue] % 60;
    return seconds;
}

#pragma mark - Downlaod and data creation


-(NSArray <NSNumber *> *)constructDataWithBehaviorArray:(NSArray*)array {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (int i = 0; i <= ceil([_randomUser.sessionLength doubleValue]); i++) {
        
        int numBehaviorsForTime = 0;
        for (MAXBehavior *currentBehavior in array) {
            if ([currentBehavior.elapsedTime floatValue] < i && [currentBehavior.isCorrectBehavior boolValue] == YES) {
                numBehaviorsForTime++;
            }
        }
        [tmpArray addObject:[NSNumber numberWithInt:numBehaviorsForTime]];
        
    }
    
    return tmpArray;
}

-(NSArray <NSNumber *> *)constructDataWithReinforcerArray:(NSArray *)array {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (int i = 0; i < ceilf([_randomUser.sessionLength doubleValue]); i++) {
        
        int numReinforcersForTime = 0;
        for (MAXReinforcer *currentReinforcer in array) {
            if ([currentReinforcer.elapsedTime floatValue] < i) {
                numReinforcersForTime++;
            }
        }
        [tmpArray addObject:[NSNumber numberWithInt:numReinforcersForTime]];
        
    }
    
    return tmpArray;
    
}

#pragma mark - Chart Data

-(NSInteger)numberOfLines {
    return 1;
}

-(NSUInteger)numberOfVerticalValuesAtIndes:(NSUInteger)lineIndex {
    NSLog(@"chart data count: %d", (int)_behaviorChartData.count);

    return _behaviorChartData.count;
}

-(CGFloat)highestYValue {
    
    return 1200;
}

-(CGFloat)verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex {
    
    if (horizontalIndex >= _behaviorChartData.count) {
        return [[NSNumber numberWithFloat:NAN] floatValue];
        return [(NSNumber*)[_behaviorChartData lastObject] unsignedIntegerValue];
    }
    
    return [(NSNumber*)[_behaviorChartData objectAtIndex:horizontalIndex] unsignedIntValue];
}


#pragma mark - Reinforcer decoration data

-(NSInteger)numberOfReinforcers {
    
    return _reinforcerArray.count;
}

-(double)horizontalValueForReinforcerAtIndex:(NSUInteger)theIndex {
    
    double elapsedTime = [[(MAXReinforcer *)[_reinforcerArray objectAtIndex: theIndex] elapsedTime] doubleValue];
    
    return elapsedTime;
}

@end
