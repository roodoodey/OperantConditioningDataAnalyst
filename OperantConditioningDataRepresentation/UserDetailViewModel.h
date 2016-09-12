//
//  UserDetailViewModel.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class MAXRandomUser;

@interface UserDetailViewModel : NSObject

-(id)initWithUser:(MAXRandomUser *)theRandomUser;

-(NSString *)userId;
-(NSString *)sessionLength;
-(NSString *)avgBehavior;
-(NSString *)stdDevBehavior;
-(NSString *)avgReinforcer;
-(NSString *)stdDevReinforcer;
-(NSString *)userGender;
-(NSString *)userPlayFreq;
-(NSString *)userPlayAmount;
-(NSString *)maxXValue;
-(NSString *)maxYValue;

-(BOOL)sessionLengthIncorrect;
-(BOOL)isExcluded;
-(void)includeOrExcludeData;

// chart data
-(NSInteger)numberOfLines;
-(NSUInteger)numberOfVerticalValuesAtIndes:(NSUInteger)lineIndex;
-(CGFloat)verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex;

// Reinforcer decoration view data
-(NSInteger)numberOfReinforcers;
-(double)horizontalValueForReinforcerAtIndex:(NSUInteger)theIndex;

@end
