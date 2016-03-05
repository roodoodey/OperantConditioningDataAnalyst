//
//  RandomUser.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Parse/Parse.h>


@interface RandomUser : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSNumber *sessionLength;
@property (nonatomic, strong) NSNumber *reinforcementSchedule;

/* Answers to questionnaire */
@property (nonatomic, strong) NSNumber *playingAmount;
@property (nonatomic, strong) NSNumber *playingFrequency;

+(NSString*)parseClassName;

@end
