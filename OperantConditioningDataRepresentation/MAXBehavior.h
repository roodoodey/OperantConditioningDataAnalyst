//
//  MAXBehavior.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 05/03/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAXBehavior : NSObject

@property (nonatomic, strong) NSNumber *elapsedTime;
@property (nonatomic, strong) NSNumber *isCorrectBehavior;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *userId;

@end
