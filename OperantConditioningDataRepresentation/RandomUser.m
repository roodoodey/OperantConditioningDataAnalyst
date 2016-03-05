//
//  RandomUser.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "RandomUser.h"

@implementation RandomUser

@dynamic uniqueId;
@dynamic gender;
@dynamic age;
@dynamic sessionLength;
@dynamic reinforcementSchedule;

@dynamic playingAmount;
@dynamic playingFrequency;

+(void)load {
    [self registerSubclass];
}

+(NSString*)parseClassName {
    return @"RandomUser";
}

@end
