//
//  Behavior.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Parse/Parse.h>

@interface Behavior : PFObject <PFSubclassing>

@property (nonatomic, strong) NSNumber *elapsedTime;
@property (nonatomic, strong) NSNumber *isCorrectBehavior;
@property (nonatomic, strong) NSString *userId;

@end
