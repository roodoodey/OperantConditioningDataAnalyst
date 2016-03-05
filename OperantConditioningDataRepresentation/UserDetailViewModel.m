//
//  UserDetailViewModel.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UserDetailViewModel.h"
#import "Behavior.h"
#import "Reinforcer.h"
#import "RandomUser.h"
#import "UserDefaults.h"
#import "Constants.h"

@interface UserDetailViewModel () {
    RandomUser *_randomUser;
    NSMutableArray *_behaviorArray;
    NSArray *_reinforerArray;
    NSMutableArray *_behaviorChartData;
    NSArray *_reinforcerChartData;
}

@end

const int maxTimePlayed = 610;

@implementation UserDetailViewModel

-(id)initWithUser:(RandomUser *)theRandomUser {
    if (self = [super init]) {
        _randomUser = theRandomUser;
        _behaviorArray = [NSMutableArray array];
        _behaviorChartData = [NSMutableArray array];
        _reinforerArray = [NSArray array];
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
    
    NSLog(@"seconds are: %@", seconds);
    
    return [NSString stringWithFormat:@"%@ : %@", minutes, seconds];
}

-(NSString*)avgBehavior {
    NSLog(@"average behavior is: %.02f", [self averageBehavior30Sec]);
    return [NSString stringWithFormat:@"%.02f", [self averageBehavior30Sec]];
}

-(NSString*)stdDevBehavior {
    return [NSString stringWithFormat:@"%.02f", [self standardDeviationBehavior30Sec]];
}

-(NSString*)avgReinforcer {
    return [NSString stringWithFormat:@"%.02f", [self averageReinforcer]];
}

-(NSString*)stdDevReinforcer {
    return [NSString stringWithFormat:@"%.02f", [self standardDeviationReinforcer]];
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
    return [NSString stringWithFormat:@"%d", 610];
    //return [NSString stringWithFormat:@"%d", (int)ceil([_randomUser.sessionLength doubleValue])];
}

-(NSString*)maxYValue {
    return [NSString stringWithFormat:@"%d", 1100];
    //return [NSString stringWithFormat:@"%d", (int)[_behaviorArray count]];
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
    NSLog(@"minutes are: %d", minutes);
    return minutes;
}

-(NSInteger)sessionLengthSeconds {
    int seconds = [_randomUser.sessionLength intValue] % 60;
    return seconds;
}

-(float)averageBehavior30Sec {

    return [self averageBehvavior] * 30;
}

-(float)averageBehvavior {
    double averagePerSecond = (double) _behaviorArray.count / [_randomUser.sessionLength doubleValue];
    return averagePerSecond;
}

-(float)standardDeviationBehavior30Sec {
    
    return [self standardDeviationBehavior] * 30;
}

-(float)standardDeviationBehavior {
    
    return 0;
    
    float sumOfVariance = 0;
    
    for (NSNumber *numBehaviorsAtTime in _behaviorChartData) {
        sumOfVariance += pow([numBehaviorsAtTime doubleValue] - [self averageBehvavior], 2);
    }
    
    sumOfVariance = sumOfVariance / (float)_behaviorChartData.count;
    sumOfVariance = sqrtf(sumOfVariance);
    
    return sumOfVariance;
    
}

-(float)averageReinforcer {
    double averagePerSecond = (double) _reinforerArray.count / [_randomUser.sessionLength doubleValue];
    return averagePerSecond * 30;
}

-(float)standardDeviationReinforcer {
    
    float sum = 0;
    float avgReinforcer = [self averageReinforcer];
    
    for (int i = 0; i < _reinforcerChartData.count; i++) {
        
        int numToDeduct = 0;
        if (i != 0) {
            numToDeduct = [(NSNumber*)[_reinforcerChartData objectAtIndex:i - 1] intValue];
        }
        
        int currentNum = [(NSNumber*)[_reinforcerChartData objectAtIndex:i] intValue] - numToDeduct;
        
        sum += pow(currentNum - avgReinforcer, 2);
    }
    
    sum = sum / (float)_reinforcerChartData.count;
    sum = sqrtf(sum);
    
    return sum * 30;
}

#pragma mark - Downlaod and data creation

-(void)downloadReinforcersWithCompletion:(void (^)(NSError *))block {
    [block copy];
    
    PFQuery *query = [Reinforcer query];
    query.limit = 1000;
    [query whereKey:@"userId" equalTo:_randomUser.objectId];
    
    __weak typeof (self) wSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if (error == nil) {
            NSLog(@"objects are: %@", objects);
            _reinforerArray = objects;
            _reinforcerChartData = [wSelf constructDataWithReinforcerArray:_reinforerArray];
            block(nil);
        }
        else {
            block(error);
        }
        
    }];
}

-(void)downloadBehaviorSKipping:(NSInteger)itemsToSkip withCompletion:(void (^)(NSError *error))block {
    [block copy];
    
    
    
    PFQuery *query = [Behavior query];
    query.limit = 1000;
    query.skip = itemsToSkip;
    [query whereKey:@"userId" equalTo:_randomUser.objectId];
    [query whereKey:@"isCorrectBehavior" equalTo:[NSNumber numberWithBool:YES]];
    
    __weak typeof (self) wSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (error == nil) {
                NSLog(@"objects are: %@", objects);
                 [_behaviorArray addObjectsFromArray:objects];
                _behaviorChartData = [NSMutableArray arrayWithArray:[self constructDataWithBehaviorArray:_behaviorArray]];
                if (objects.count != 1000) {
                    block(nil);
                }
                else {
                    [wSelf downloadBehaviorSKipping:itemsToSkip + 1000 withCompletion:block];
                }
            }
            else {
                block(error);
            }
            
        });
    }];
}

-(void)downloadBehaviorAndReinforcersWithCompletion:(void (^)(NSError *))block {
    [block copy];
    
    __block BOOL allDownloaded = NO;
    __block NSError *tmpError;
    
    [self downloadBehaviorSKipping:0 withCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (allDownloaded) {
                if (tmpError) {
                    block(tmpError);
                }
                else {
                    block(error);
                }
            }
            else {
                tmpError = error;
                allDownloaded = YES;
            }
        });
    }];
    
    [self downloadReinforcersWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (allDownloaded) {
                if (tmpError) {
                    block(tmpError);
                }
                else {
                    block(error);
                }
            }
            else {
                tmpError = error;
                allDownloaded = YES;
            }
        });
    }];
}

-(NSArray*)constructDataWithBehaviorArray:(NSArray*)array {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    NSLog(@"session length is: %f", ceil([_randomUser.sessionLength doubleValue]));
    
    for (int i = 0; i <= ceil([_randomUser.sessionLength doubleValue]); i++) {
        
        int numBehaviorsForTime = 0;
        for (Behavior *currentBehavior in array) {
            if ([currentBehavior.elapsedTime floatValue] < i && [currentBehavior.isCorrectBehavior boolValue] == YES) {
                numBehaviorsForTime++;
            }
        }
        [tmpArray addObject:[NSNumber numberWithInt:numBehaviorsForTime]];
        
    }
    
    return tmpArray;
}

-(NSArray*)constructDataWithReinforcerArray:(NSArray *)array {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (int i = 0; i < ceilf([_randomUser.sessionLength doubleValue]); i++) {
        
        int numReinforcersForTime = 0;
        for (Reinforcer *currentReinforcer in array) {
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
    //return maxTimePlayed;
    return 610;
}

-(CGFloat)verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex {
    //NSLog(@"vertical value at index: %d, value: %d", (int)horizontalIndex, (int)[(NSNumber*)[_behaviorChartData objectAtIndex:horizontalIndex] intValue]);
    
    if (horizontalIndex >= _behaviorChartData.count) {
        return [[NSNumber numberWithFloat:NAN] floatValue];
        return [(NSNumber*)[_behaviorChartData lastObject] unsignedIntegerValue];
    }
    
    return [(NSNumber*)[_behaviorChartData objectAtIndex:horizontalIndex] unsignedIntValue];
}


@end
