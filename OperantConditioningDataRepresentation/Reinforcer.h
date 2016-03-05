//
//  Reinforcer.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 08/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Parse/Parse.h>

@interface Reinforcer : PFObject <PFSubclassing>

@property (nonatomic, strong) NSNumber *elapsedTime;
@property (nonatomic, strong) NSString *userId;

@end
