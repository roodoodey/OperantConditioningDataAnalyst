//
//  UserDetailViewModel.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class  RandomUser;

@interface UserDetailViewModel : NSObject

-(id)initWithUser:(RandomUser*)theRandomUser;

-(void)downloadBehaviorWithCompletion:(void (^)(NSError *error))block;
-(void)downloadReinforcersWithCompletion:(void (^)(NSError *error))block;
-(void)downloadBehaviorAndReinforcersWithCompletion:(void (^)(NSError *error))block;

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

@end
