//
//  Reinforcer.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 08/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "Reinforcer.h"

@implementation Reinforcer

@dynamic elapsedTime;
@dynamic userId;

+(void)load {
    [self registerSubclass];
}

+(NSString*)parseClassName {
    return @"Reinforcer";
}

@end
