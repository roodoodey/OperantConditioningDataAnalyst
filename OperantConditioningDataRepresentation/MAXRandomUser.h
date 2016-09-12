//
//  MAXRandomUser.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 05/03/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAXRandomUser : NSObject

@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSNumber *playingAmount;
@property (nonatomic, strong) NSNumber *playingFrequency;
@property (nonatomic, strong) NSNumber *reinforcementSchedule;
@property (nonatomic, strong) NSNumber *sessionLength;

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *userId;

@end
