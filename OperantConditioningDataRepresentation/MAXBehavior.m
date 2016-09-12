//
//  MAXBehavior.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 05/03/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import "MAXBehavior.h"

@implementation MAXBehavior

-(NSString*)description {
    return [NSString stringWithFormat:@"objectId: %@, userId: %@ time elapsed is: %@, is correct: %d", self.objectId, self.userId, self.elapsedTime, [self.isCorrectBehavior boolValue]];
}

@end
