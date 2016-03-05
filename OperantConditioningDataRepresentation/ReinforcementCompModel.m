//
//  ReinforcementCompModel.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 10/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "ReinforcementCompModel.h"
#import "RandomUser.h"
#import "Behavior.h"
#import "Reinforcer.h"
#import "Constants.h"
#import "Chameleon.h"
#import "Constants.h"
#import "UserDefaults.h"


@interface ReinforcementCompModel () {
    NSArray *_users;
    
    NSMutableArray *_behaviorData;
    NSMutableArray *_behaviorChartData;
    
    NSMutableArray *_reinforcerData;
    NSMutableArray *_reinforcerChartData;
}

@end

@implementation ReinforcementCompModel

-(id)initWithUsers:(NSArray *)theUsers {
    if (self = [super init]) {
        _users = theUsers;
        _users = [self removeExcludedUSers];
        
        _behaviorData = [NSMutableArray array];
        
        
        _reinforcerData = [NSMutableArray array];
        
    }
    
    return self;
}

-(NSArray*)removeExcludedUSers {
    NSMutableArray *notExcludedUser = [NSMutableArray arrayWithArray:_users];
    
    NSLog(@"Users before exclusion: %d", (int)notExcludedUser.count);
    
    NSArray *excludedUsers = [UserDefaults excludedUsers];
    for (RandomUser *randomUser in _users) {
        
        for (NSString *excludedUserId in excludedUsers) {
            if ([excludedUserId isEqualToString:randomUser.objectId]) {
                [notExcludedUser removeObject:randomUser];
            }
        }
    }
    
    NSLog(@"users after exclusion: %d", (int)notExcludedUser.count);
    
    return notExcludedUser;
}


#pragma mark - Block 

-(NSString*)stringTitleForRow:(NSUInteger)theRow col:(NSUInteger)theCol {
    
    if (theRow == 0 || theRow == 1 || theRow == 2 || theRow == 3) {
        if (theCol == 0) {
            return @"Avg. Behavior (30 sec)";
        }
        else if(theCol == 1) {
            return @"Avg. Reinforcer (30 sec)";
        }
    }
    
    return @"";
}

-(NSString*)stringForRow:(NSUInteger)theRow col:(NSUInteger)theCol {
    
    if (theRow == 0) {
        
        if (theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [self avgBehaviorForSchedule:kFISchedule forBehaviorData:_behaviorChartData] * 30.0];
        }
        else if(theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [self avgReinforcerForSchedule:kFISchedule forReinforcerData:_reinforcerChartData] * 30.0];
        }
        
    }
    else if(theRow == 1) {
        
        if (theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [self avgBehaviorForSchedule:kVISchedule forBehaviorData:_behaviorChartData] * 30.0];
        }
        else if(theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [self avgReinforcerForSchedule:kVISchedule forReinforcerData:_reinforcerChartData] * 30.0];
        }
        
    }
    else if(theRow == 2) {
        if (theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [self avgBehaviorForSchedule:kFRSchedule forBehaviorData:_behaviorChartData] * 30.0];
        }
        else if(theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [self avgReinforcerForSchedule:kFRSchedule forReinforcerData:_reinforcerChartData] * 30.0];
        }
    }
    else if(theRow == 3) {
        if (theCol == 0) {
            return [NSString stringWithFormat:@"%.02f", [self avgBehaviorForSchedule:kVRSchedule forBehaviorData:_behaviorChartData] * 30.0];
        }
        else if(theCol == 1) {
            return [NSString stringWithFormat:@"%.02f", [self avgReinforcerForSchedule:kVRSchedule forReinforcerData:_reinforcerChartData] * 30.0];
        }
    }
    
    return @"";
}



-(float)avgBehaviorForSchedule:(NSUInteger)theSchedule forBehaviorData:(NSArray*)theBehaviorData {
    float numBehaviors = 0;
    
    NSArray *usersForLine = [self usersForSchedule:theSchedule];
    for (RandomUser *randomUser in usersForLine) {
        numBehaviors += [self behaviorForUser:randomUser chartData:theBehaviorData].count / [randomUser.sessionLength floatValue];
    }
    
    return numBehaviors / usersForLine.count;
}

-(float)avgReinforcerForSchedule:(NSUInteger)theSchedule forReinforcerData:(NSArray*)theReinforcerData {
    float numReinforcers = 0;
    
    NSArray *usersForSchedule = [self usersForSchedule:theSchedule];
    for (RandomUser *randomUser in usersForSchedule) {
        numReinforcers += [self reinforcerForUser:randomUser chartData:theReinforcerData].count / [randomUser.sessionLength floatValue];
    }
    
    return numReinforcers / usersForSchedule.count;
    
}

-(NSArray*)usersForSchedule:(NSUInteger)theScheduleType {
    NSMutableArray *usersForSched = [NSMutableArray array];
    
    for (RandomUser *user in _users) {
        if ([user.reinforcementSchedule intValue] == theScheduleType) {
            [usersForSched addObject:user];
        }
    }
    
    return usersForSched;
}

-(NSArray*)behaviorForUser:(RandomUser*)theRandomUser chartData:(NSArray*)theChartData {
    for (NSArray *userBehavior in theChartData) {
        Behavior *firstBehav = [userBehavior firstObject];
        
        if ([firstBehav.userId isEqualToString:theRandomUser.objectId]) {
            return userBehavior;
        }
        
    }
    
    return nil;
}

-(NSArray*)reinforcerForUser:(RandomUser*)theRandomUser chartData:(NSArray*)theChartData {
    for (NSArray *userReinforcer in theChartData) {
        
        Reinforcer *firstReinf = [userReinforcer firstObject];
        
        if ([firstReinf.userId isEqualToString:theRandomUser.objectId]) {
            return userReinforcer;
        }
        
    }
    
    return nil;
}


#pragma mark - Chart

-(NSInteger)numLines {
    return _behaviorChartData.count;
}

-(NSUInteger)numVerticalValuesForLine:(NSUInteger)theLineIndex {
    
    if (theLineIndex < _behaviorChartData.count) {
        float elapsedTimeLast = [[(Behavior*)[(NSArray*)[_behaviorChartData objectAtIndex:theLineIndex] lastObject] elapsedTime] floatValue];
        
        return ceilf(elapsedTimeLast);
        
    }
    
    return 0;
}

-(CGFloat)verticalValueForHorizontalIndex:(NSUInteger)theHorizIndex forLineIndex:(NSUInteger)theLindeIndex {
    
    NSArray *lineValues = [_behaviorChartData objectAtIndex:theLindeIndex];
    
    float value = 0;
    
    for (int i = 0; i < lineValues.count; i++) {
        Behavior *behavior = [lineValues objectAtIndex:i];
       
        if ([behavior.elapsedTime floatValue] < theHorizIndex ) {
            value++;
        }
    }
    
    value /= (float)[self numVerticalValuesForLine:theLindeIndex];
    
    return value;
}

-(UIColor*)colorForLineAtIndex:(NSUInteger)theLineIndex {
    if (theLineIndex == 0) {
        return [UIColor flatBlueColor];
    }
    else if(theLineIndex == 1) {
        return [UIColor flatRedColor];
    }
    else if(theLineIndex == 2) {
        return [UIColor flatYellowColor];
    }
    else if(theLineIndex == 3) {
        return [UIColor flatGreenColor];
    }
    
    return [UIColor flatPinkColor];
}

-(int)numUsersForLineIndex:(int)theLineIndex {
    
    int numUsers = 0;
    
    for (RandomUser *user in _users) {
        if (theLineIndex == 0  && [user.reinforcementSchedule intValue] == kFISchedule) {
            numUsers++;
        }
        else if(theLineIndex == 1 && [user.reinforcementSchedule intValue] == kVISchedule) {
            numUsers++;
        }
        else if(theLineIndex == 2 && [user.reinforcementSchedule intValue] == kFRSchedule) {
            numUsers++;
        }
        else if(theLineIndex == 3 && [user.reinforcementSchedule intValue] == kVRSchedule) {
            numUsers++;
        }
    }
    
    
    return numUsers;
}

#pragma mark - Download

-(void)downloadBehaviorWithUserId:(NSString *)theObjectId withCompletion:(void (^)(NSError *))block {
    [block copy];
    
    PFQuery *query = [Behavior query];
    query.limit = 1000;
    [query whereKey:@"isCorrectBehavior" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByAscending:@"objectId"];
    [query orderByAscending:@"elapsedTime"];
    
    if (theObjectId != nil) {
        [query whereKey:@"objectId" greaterThan:theObjectId];
    }
    
    __weak typeof (self) wSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *theError) {

        [_behaviorData addObjectsFromArray:objects];
        
        if (theError == nil && objects.count == 1000) {
            [wSelf downloadBehaviorWithUserId:[(Behavior*)[objects lastObject] objectId] withCompletion:block];
        }
        else if(theError == nil) {
            _behaviorChartData = [wSelf createBehaviorPerReinforcerTypeWithData:_behaviorData];
            dispatch_async(dispatch_get_main_queue(), ^{
               block(nil);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
               block(theError); 
            });
        }
        
    }];
    
}

-(void)downloadReinforcerWithUserId:(NSString *)theObjectId withCompletion:(void (^)(NSError *))block {
    [block copy];
    
    PFQuery *query = [Reinforcer query];
    query.limit = 1000;
    [query orderByAscending:@"objectId"];
    
    if (theObjectId != nil) {
        [query whereKey:@"objectId" greaterThan:theObjectId];
    }
    
    __weak typeof (self) wSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *theError) {
        
        if (theError == nil && objects.count == 1000) {
            
            [_reinforcerData addObjectsFromArray:objects];
            
            [wSelf downloadReinforcerWithUserId:[(Reinforcer*)[objects lastObject] objectId] withCompletion:block];
            
        }
        else if(theError == nil) {
            
            [_reinforcerData addObjectsFromArray:objects];
            _reinforcerChartData = [wSelf createReinforcerPerReinforcerTypeWithData:_reinforcerData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
               block(nil);
            });
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
               block(theError);
            });
            
        }
        
    }];
    
}

-(NSMutableArray*)createBehaviorPerReinforcerTypeWithData:(NSArray*)theBehaviorData {
    
    NSMutableArray *theDynamicBehaviorData = [NSMutableArray arrayWithArray:theBehaviorData];
    
    NSMutableArray *FI = [NSMutableArray array];
    NSMutableArray *VI = [NSMutableArray array];
    
    NSMutableArray *FR = [NSMutableArray array];
    NSMutableArray *VR = [NSMutableArray array];
    
    for (RandomUser *currentUser in _users) {
        
        for (int i = 0; i < theDynamicBehaviorData.count; i++) {
            Behavior *theBehavior = [theDynamicBehaviorData objectAtIndex:i];
            
            if ([theBehavior.userId isEqualToString:currentUser.objectId]) {
                
                if ([currentUser.reinforcementSchedule intValue] == kFISchedule) {
                    [FI addObject:theBehavior];
                }
                else if([currentUser.reinforcementSchedule intValue] == kVISchedule) {
                    [VI addObject:theBehavior];
                }
                else if([currentUser.reinforcementSchedule intValue] == kFRSchedule) {
                    [FR addObject:theBehavior];
                }
                else if([currentUser.reinforcementSchedule intValue] == kVRSchedule) {
                    [VR addObject:theBehavior];
                }
                
                [theDynamicBehaviorData removeObject:theBehavior];
                
            }
        }
        
    }
    
    NSSortDescriptor *sortElapsedTime = [[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending:YES];
    
    FI = [NSMutableArray arrayWithArray:[FI sortedArrayUsingDescriptors:@[sortElapsedTime]]];
    VI = [NSMutableArray arrayWithArray:[VI sortedArrayUsingDescriptors:@[sortElapsedTime]]];
    FR = [NSMutableArray arrayWithArray:[FR sortedArrayUsingDescriptors:@[sortElapsedTime]]];
    VR = [NSMutableArray arrayWithArray:[VR sortedArrayUsingDescriptors:@[sortElapsedTime]]];
    
    
    return [NSMutableArray arrayWithObjects:FI, VI, FR, VR, nil];
}

-(NSMutableArray*)createReinforcerPerReinforcerTypeWithData:(NSArray*)theBehaviorData {
    
    NSMutableArray *tmpReinforcerData = [NSMutableArray arrayWithArray:theBehaviorData];
    
    NSMutableArray *FI = [NSMutableArray array];
    NSMutableArray *VI = [NSMutableArray array];
    NSMutableArray *FR = [NSMutableArray array];
    NSMutableArray *VR = [NSMutableArray array];
    
    for (RandomUser *user in _users) {
        
        for (int i = 0; i < tmpReinforcerData.count; i++) {
            
            Reinforcer *theReinfocer = [tmpReinforcerData objectAtIndex:i];
            
            if ([theReinfocer.userId isEqualToString:user.objectId]) {
                
                if ([user.reinforcementSchedule intValue] == kFISchedule) {
                    [FI addObject:theReinfocer];
                }
                else if([user.reinforcementSchedule intValue] == kVISchedule) {
                    [VI addObject:theReinfocer];
                }
                else if([user.reinforcementSchedule intValue] == kFRSchedule) {
                    [FR addObject:theReinfocer];
                }
                else if([user.reinforcementSchedule intValue] == kVRSchedule) {
                    [VR addObject:theReinfocer];
                }
                
                [tmpReinforcerData removeObject:theReinfocer];
            }
            
        }
        
    }
    
    return [NSMutableArray arrayWithObjects:FI, VI, FR, VR, nil];
    
}

@end
