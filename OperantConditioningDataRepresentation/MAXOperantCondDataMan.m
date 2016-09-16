//
//  MAXOperantCondDataMan.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 05/03/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import "MAXOperantCondDataMan.h"
#import "MNFJsonAdapter.h"
#import "MAXBehavior.h"
#import "MAXReinforcer.h"
#import "MAXRandomUser.h"

@interface MAXOperantCondDataMan () {
    NSBundle *_currentBundle;
}

@end

@implementation MAXOperantCondDataMan


-(id)init {
    return [self initWithBundle:[NSBundle mainBundle]];
}

-(id)initWithBundle:(NSBundle *)theBundle {
    if (self = [super init]) {
        
        if (theBundle != nil) {
            _currentBundle = theBundle;
        }
        else {
            _currentBundle = [NSBundle mainBundle];
        }
        
        self.behavior = [MNFJsonAdapter objectsOfClass:[MAXBehavior class] jsonArray:[self p_dataForResource:@"Behavior" withType:@"json"] option:kMNFAdapterOptionNoOption error:nil];
        
        self.reinforcers = [MNFJsonAdapter objectsOfClass:[MAXReinforcer class] jsonArray:[self p_dataForResource:@"Reinforcer" withType:@"json"] option:kMNFAdapterOptionNoOption error:nil];
        
        self.allUsers = [MNFJsonAdapter objectsOfClass:[MAXRandomUser class] jsonArray:[self p_dataForResource:@"RandomUser" withType:@"json"] option:kMNFAdapterOptionNoOption error:nil];
        
        self.users = [self p_validUsersFromAllUsers:self.allUsers];
        
        self.correctBehavior = [self p_correctBehaviorFromBehaviorArray:self.behavior];
    }
    
    return self;
}

-(id)initWithBundle:(NSBundle *)theBundle behaviorFile:(NSString *)theBehaviorFile behaviorFileType:(NSString *)theBehaviorFileType reinforcementFile:(NSString *)theReinforcementFile reinforcementFileType:(NSString *)theReinforcementFileType userFile:(NSString *)theUserFile userFileType:(NSString *)theUserFileType{
    
    if (self = [super init]) {
        
        if (theBundle != nil) {
            _currentBundle = theBundle;
        }
        else {
            _currentBundle = [NSBundle mainBundle];
        }
        
        self.behavior = [MNFJsonAdapter objectsOfClass:[MAXBehavior class] jsonArray:[self p_dataForResource:theBehaviorFile withType:theBehaviorFileType] option:kMNFAdapterOptionNoOption error:nil];
        
        self.reinforcers = [MNFJsonAdapter objectsOfClass:[MAXReinforcer class] jsonArray:[self p_dataForResource:theReinforcementFile withType:theReinforcementFileType] option:kMNFAdapterOptionNoOption error:nil];
        
        self.allUsers = [MNFJsonAdapter objectsOfClass:[MAXRandomUser class] jsonArray:[self p_dataForResource:theUserFile withType:theUserFileType] option:kMNFAdapterOptionNoOption error:nil];
        
        self.users = [self p_validUsersFromAllUsers:self.allUsers];
        
        self.correctBehavior = [self p_correctBehaviorFromBehaviorArray:self.behavior];
        
    }
    
    return self;
}

#pragma mark - Data Getters

-(NSArray*)usersWithReinforcementSchedule:(ReinforcementSchedule)theReinforcementSchedule {
    NSMutableArray *array = [NSMutableArray array];
    for (MAXRandomUser *randomUser in self.users) {
        if ([randomUser.reinforcementSchedule intValue] == theReinforcementSchedule) {
            [array addObject:randomUser];
        }
    }
    
    return array;
}

-(NSArray <MAXRandomUser *> *)usersWithIds:(NSArray<NSString *> *)theIds {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *currentId in theIds) {
        
        for (MAXRandomUser *currentUser in self.users) {
            if ([currentUser.objectId isEqualToString: currentId] == YES) {
                [array addObject: currentUser];
            }
        }
        
    }
    
    return array;
}

-(NSArray <NSArray <MAXReinforcer *> *> *)behaviorForUsersByUser:(NSArray *)theUsers {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < theUsers.count; i++) {
        MAXRandomUser *randUser = [theUsers objectAtIndex:i];
        
        NSMutableArray *behaviorForUser = [NSMutableArray array];
        for (MAXBehavior *behavior in self.correctBehavior) {
            
            if ([behavior.userId isEqualToString:randUser.objectId] == YES) {
                [behaviorForUser addObject:behavior];
            }
            
        }
        [array addObject:behaviorForUser];
    }
    
    return array;
}

-(NSArray <NSArray <MAXReinforcer *> *> *)reinforcerForUsersByUsers:(NSArray *)theUsers {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < theUsers.count; i++) {
        MAXRandomUser *randUser = [theUsers objectAtIndex:i];
        
        NSMutableArray *reinforcerForUser = [NSMutableArray array];
        for (MAXReinforcer *reinforcer in self.reinforcers) {
            
            if ([reinforcer.userId isEqualToString:randUser.objectId] == YES) {
                [reinforcerForUser addObject:reinforcer];
            }
            
        }
        
        [array addObject:reinforcerForUser];
        
    }
    
    return array;
}

-(NSArray <MAXBehavior *> *)behaviorOnlyForUsers:(NSArray *)theUsers {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (MAXRandomUser *user in theUsers) {
        NSArray *behaviorForCurrentUser = [self behaviorForUsersByUser:@[user]];
        NSArray *behavior = [behaviorForCurrentUser objectAtIndex:0];
        [array addObjectsFromArray:behavior];
    }
    
    return array;
}

-(NSArray*)reinforcerOnlyForUsers:(NSArray *)theUsers {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (MAXRandomUser *user in theUsers) {
        
        NSArray *reinforcersForCurrentUser = [self reinforcerForUsersByUsers:@[user]];
        NSArray *reinforcers = [reinforcersForCurrentUser objectAtIndex:0];
        [array addObjectsFromArray: reinforcers];
        
    }
    
    return array;
}

#pragma mark - Data Information

-(double)avgPostreinforcementTimeForUsers:(NSArray *)theUsers {
    
    double avgPostTime = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        double totalPosttimeUser = 0;
        
        NSArray <MAXReinforcer *> *reinforcersForUser = [self p_reinforcerSortedByElapsedTime:[self reinforcerOnlyForUsers: @[currentUser]] ascending:YES];
        NSArray <MAXBehavior *> *behaviorsForUser = [self p_behaviorSortedByElapsedTime:[self behaviorOnlyForUsers: @[currentUser]] ascending:YES];
        
        for (MAXReinforcer *currentReinforcer in reinforcersForUser) {
            
            MAXBehavior *nextBehavior = [self p_nextBehaviorSortedByElapsedTime: behaviorsForUser afterTime: [currentReinforcer.elapsedTime doubleValue]];
            
            if (nextBehavior != nil) {
                totalPosttimeUser += [nextBehavior.elapsedTime doubleValue] - [currentReinforcer.elapsedTime doubleValue];
            }
            
        }
        
        avgPostTime += totalPosttimeUser / reinforcersForUser.count;
        
    }
    
    avgPostTime = avgPostTime / theUsers.count;
    
    return avgPostTime;
}

-(double)stdDevPostreinforcementTimeForUsers:(NSArray *)theUsers {
    
    double stdDevPostreinforcement = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        double meanVariance = 0;
        
        NSArray <MAXReinforcer *> *reinforcersForUser = [self p_reinforcerSortedByElapsedTime:[self reinforcerOnlyForUsers: @[currentUser]] ascending:YES];
        NSArray <MAXBehavior *> *behaviorsForUser = [self p_behaviorSortedByElapsedTime:[self behaviorOnlyForUsers: @[currentUser]] ascending:YES];
        
        double averagePostreinforcementForUser = [self avgPostreinforcementTimeForUsers: @[currentUser]];
        
        for (MAXReinforcer *currentReinforcer in reinforcersForUser) {
            
            MAXBehavior *nextBehavior = [self p_nextBehaviorSortedByElapsedTime: behaviorsForUser afterTime: [currentReinforcer.elapsedTime doubleValue]];
            
            if (nextBehavior != nil) {
                double postTime = [nextBehavior.elapsedTime doubleValue] - [currentReinforcer.elapsedTime doubleValue];
                meanVariance += pow(postTime - averagePostreinforcementForUser, 2);
            }
            
        }
        
        stdDevPostreinforcement += sqrt(meanVariance / reinforcersForUser.count);
        
    }
    
    stdDevPostreinforcement = stdDevPostreinforcement / theUsers.count;
    return stdDevPostreinforcement;
}

-(double)avgMaxPostreinforcementTimeForUsers:(NSArray *)theUsers {
    
    double avgMaxPostTime = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        double maxPostTimeUser = 0;
        
        NSArray <MAXReinforcer *> *reinforcersForUser = [self p_reinforcerSortedByElapsedTime:[self reinforcerOnlyForUsers: @[currentUser]] ascending:YES];
        NSArray <MAXBehavior *> *behaviorsForUser = [self p_behaviorSortedByElapsedTime:[self behaviorOnlyForUsers: @[currentUser]] ascending:YES];
        
        for (MAXReinforcer *currentReinforcer in reinforcersForUser) {
            
            MAXBehavior *nextBehavior = [self p_nextBehaviorSortedByElapsedTime: behaviorsForUser afterTime: [currentReinforcer.elapsedTime doubleValue]];
            
            if (nextBehavior != nil) {
                double postTime = [nextBehavior.elapsedTime doubleValue] - [currentReinforcer.elapsedTime doubleValue];
                if (postTime > maxPostTimeUser) {
                    maxPostTimeUser = postTime;
                }
            }
        }
        
        avgMaxPostTime += maxPostTimeUser;
    }
    
    avgMaxPostTime = avgMaxPostTime / theUsers.count;

    return avgMaxPostTime;
}

-(double)avgMinPostreinforcementTimeForUsers:(NSArray *)theUsers {
    
    double avgMinPostTime = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        double minPostTimeUser = INFINITY;
        
        NSArray <MAXReinforcer *> *reinforcersForUser = [self p_reinforcerSortedByElapsedTime:[self reinforcerOnlyForUsers: @[currentUser]] ascending:YES];
        NSArray <MAXBehavior *> *behaviorsForUser = [self p_behaviorSortedByElapsedTime:[self behaviorOnlyForUsers: @[currentUser]] ascending:YES];
        
        for (MAXReinforcer *currentReinforcer in reinforcersForUser) {
            
            MAXBehavior *nextBehavior = [self p_nextBehaviorSortedByElapsedTime: behaviorsForUser afterTime: [currentReinforcer.elapsedTime doubleValue]];
            if (nextBehavior != nil) {
                
                double postTime = [nextBehavior.elapsedTime doubleValue] - [currentReinforcer.elapsedTime doubleValue];
                
                if (postTime < minPostTimeUser) {
                    minPostTimeUser = postTime;
                }
                
            }
            
        }
        
        avgMinPostTime += minPostTimeUser;
        
    }
    
    avgMinPostTime = avgMinPostTime / theUsers.count;
    
    return avgMinPostTime;
}

-(float)avgBehaviorForUsers:(NSArray *)theUsers {
    
    float amountOfBehavior = 0;
    for (MAXRandomUser *user in theUsers) {
        NSArray *behavior = [[self behaviorForUsersByUser:@[user]] objectAtIndex:0];
        amountOfBehavior += behavior.count / [user.sessionLength floatValue];
    }
    
    return amountOfBehavior / theUsers.count;
}


-(float)avgReinforcerForUsers:(NSArray *)theUsers {
    
    float amountOfReinforcers = 0;
    for (MAXRandomUser *user in theUsers) {
        NSArray *reinforcers = [[self reinforcerForUsersByUsers:@[user]] objectAtIndex:0];
        amountOfReinforcers += reinforcers.count / [user.sessionLength floatValue];
    }
    
    return amountOfReinforcers / theUsers.count;
}

-(float)avgTimeForUsers:(NSArray *)theUsers {
    float elapsedTime = 0;
    for (MAXRandomUser *user in theUsers) {
        elapsedTime += [user.sessionLength floatValue];
    }
    
    return elapsedTime / theUsers.count;
}

-(float)stdDevBehaviorForUsers:(NSArray *)theUsers {
    
    float totalStdDev = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        float meanVariance = 0;
        
        NSArray *behaviorForUser = [self behaviorOnlyForUsers: @[currentUser] ];
        float averageBehavior = [self avgBehaviorForUsers: @[currentUser] ];
        int sessionLength = [currentUser.sessionLength intValue];
        
        for (int i = 0; i < sessionLength; i += 1) {
            
            NSRange range = NSMakeRange(i, 1);
            int numBehaviorsInRange = [self numBehaviors:behaviorForUser inRange:range];

            meanVariance += powf(numBehaviorsInRange - averageBehavior, 2);
        }

        totalStdDev += sqrtf(meanVariance / (double)sessionLength);
        
        NSLog(@"the average behavior: %f", averageBehavior);
        NSLog(@"std dev: %f", totalStdDev);
        
    }
    
    //float stdDev = sqrtf(meanVariance / 20.0f);
    float stdDev = totalStdDev / theUsers.count;
    return stdDev;
}

-(float)stdDevReinforcerForUsers:(NSArray *)theUsers {
    
    float totalStdDev = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        float meanVariance = 0;
        
        NSArray <MAXReinforcer *> *reinforcersForUser = [self reinforcerOnlyForUsers: @[currentUser]];
        float averageReinforcer = [self avgReinforcerForUsers: @[currentUser]];
        int sessionLength = [currentUser.sessionLength intValue];
        
        for (int i = 0; i < sessionLength; i++) {
            
            NSRange range = NSMakeRange(i, 1);
            int numReinforcersInRange = [self numReinforcers: reinforcersForUser inRange: range];
            
            meanVariance += pow(numReinforcersInRange - averageReinforcer, 2);
            
        }
        
        totalStdDev += sqrt(meanVariance / (double)sessionLength);
        
    }
    
    float stdDev = totalStdDev / (double)theUsers.count;
    
    return stdDev;
    
}

-(float)stdDevTimeForUsers:(NSArray *)theUsers {
    
    float averageTime = [self avgTimeForUsers:theUsers];
    
    float meanVariance = 0;
    
    for (MAXRandomUser *user in theUsers) {
        meanVariance += powf([user.sessionLength floatValue] - averageTime, 2);
    }
    
    float stdDev = sqrtf(meanVariance / (float)theUsers.count);
    return stdDev;
}

-(int)numBehaviors:(NSArray *)theBehavior inRange:(NSRange)theRange {
    
    int numInRange = 0;
    for (MAXBehavior *behavior in theBehavior) {
        if ([self isElapsedTime:[behavior.elapsedTime floatValue] withinRange:theRange] == YES) {
            numInRange++;
        }
    }
    
    return numInRange;
}

-(int)numReinforcers:(NSArray *)theReinforcer inRange:(NSRange)theRange {
    
    int numInRange = 0;
    for (MAXReinforcer *reinforcer in theReinforcer) {
        if ([self isElapsedTime:[reinforcer.elapsedTime floatValue] withinRange:theRange] == YES) {
            numInRange++;
        }
    }
    
    return numInRange;
}

-(BOOL)isElapsedTime:(float)theTime withinRange:(NSRange)theRange {
    if (theTime > theRange.location && theTime <= (theRange.location + theRange.length)) {
        return YES;
    }
    return NO;
}

#pragma mark - Helpers


-(MAXBehavior *)p_nextBehaviorSortedByElapsedTime:(NSArray <MAXBehavior *> *)theBehaviors afterTime:(double)theTime {
    
    MAXBehavior *behavior = nil;
    
    for (MAXBehavior *currentBehavior in theBehaviors) {
        
        if ([currentBehavior.elapsedTime doubleValue] > theTime) {
            behavior = currentBehavior;
            break;
        }
        
    }
    
    return behavior;
}

-(NSArray <MAXBehavior *> *)p_behaviorSortedByElapsedTime:(NSArray <MAXBehavior *> *)theBehaviors ascending:(BOOL)ascending {
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending: ascending];
    
    return [theBehaviors sortedArrayUsingDescriptors: @[descriptor]];
}

-(NSArray <MAXReinforcer *> *)p_reinforcerSortedByElapsedTime:(NSArray <MAXReinforcer *> *)theReinforcers ascending:(BOOL)ascending {
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"elapsedTime" ascending: ascending];
    
    return [theReinforcers sortedArrayUsingDescriptors: @[descriptor]];
}

-(NSArray*)p_correctBehaviorFromBehaviorArray:(NSArray*)theBehaviorArray {
    NSMutableArray *array = [NSMutableArray array];
    for (MAXBehavior *behavior in theBehaviorArray) {
        if ([behavior.isCorrectBehavior boolValue] == YES) {
            [array addObject:behavior];
        }
    }
    
    return array;
}

-(NSArray*)p_validUsersFromAllUsers:(NSArray*)allUsers {
    NSMutableArray *array = [NSMutableArray array];
    for (MAXRandomUser *randomUser in allUsers) {
        if ([randomUser.sessionLength doubleValue] >= 120 && [randomUser.sessionLength doubleValue] < 700) {
            [array addObject:randomUser];
        }
    }
    
    return array;
}


-(NSArray*)p_dataForResource:(NSString*)theResource withType:(NSString*)theType {
    NSString *filePath = [_currentBundle pathForResource:theResource ofType:theType];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
    NSArray *dataArray = [jsonDict objectForKey:@"results"];
    return dataArray;
}

@end
