//
//  Behavior.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "Behavior.h"

@implementation Behavior

@dynamic userId;
@dynamic elapsedTime;
@dynamic isCorrectBehavior;

+(void)load {
    [self registerSubclass];
}

+(NSString*)parseClassName {
    return @"Behavior";
}

@end
