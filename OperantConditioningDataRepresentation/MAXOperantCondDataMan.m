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

-(NSArray*)behaviorOnlyForUsers:(NSArray *)theUsers {
    
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
        
        NSArray *reinforcersForCurrentUser = [self behaviorOnlyForUsers:@[user]];
        NSArray *reinforcers = [reinforcersForCurrentUser objectAtIndex:0];
        [array addObject:reinforcers];
        
    }
    
    return array;
}

#pragma mark - Data Information

-(float)avgBehaviorForUsers:(NSArray *)theUsers {
    
    float amountOfBehavior = 0;
    for (MAXRandomUser *user in theUsers) {
        NSArray *behavior = [[self behaviorForUsersByUser:@[user]] objectAtIndex:0];
        amountOfBehavior += behavior.count / [user.sessionLength floatValue];
    }
    
    return amountOfBehavior / theUsers.count;
}


-(float)avgReinforcerForUsers:(NSArray *)theUsers {
    
    float amountOfREinforcers = 0;
    for (MAXRandomUser *user in theUsers) {
        NSArray *reinforcers = [[self reinforcerForUsersByUsers:@[user]] objectAtIndex:0];
        amountOfREinforcers += reinforcers.count / [user.sessionLength floatValue];
    }
    
    return amountOfREinforcers / theUsers.count;
}

-(float)avgTimeForUsers:(NSArray *)theUsers {
    float elapsedTime = 0;
    for (MAXRandomUser *user in theUsers) {
        elapsedTime += [user.sessionLength floatValue];
    }
    
    return elapsedTime / theUsers.count;
}

-(float)stdDevBehaviorForUsers:(NSArray *)theUsers {
    /*
    NSArray *behaviorForUsers = [self behaviorOnlyForUsers:theUsers];
    // multiplied by 30 because the interval is 30 seconds
    float averageBehavior = [self avgBehaviorForUsers:theUsers] * 30;
    */
    /*
    float meanVariance = 0;
    
    // interval is 30 seconds and max play time is 600 seconds, hence 20 loops
    for (int i = 0; i < 20; i++) {
        
        NSRange range = NSMakeRange(i*30, 30);
        // have to devide by the number of users
        int numBehaviorsInRange = [self numBehaviors:behaviorForUsers inRange:range] / theUsers.count;
        meanVariance += pow(numBehaviorsInRange - averageBehavior, 2);
        
    }
     */
    
    float totalStdDev = 0;
    
    for (MAXRandomUser *currentUser in theUsers) {
        
        float meanVariance = 0;
        
        NSArray *behaviorForUser = [self behaviorOnlyForUsers: @[currentUser] ];
        float averageBehavior = [self avgBehaviorForUsers: @[currentUser] ];
        
        for (int i = 0; i < [currentUser.sessionLength intValue]; i += 1) {
            
            NSRange range = NSMakeRange(i, 1);
            int numBehaviorsInRange = [self numBehaviors:behaviorForUser inRange:range];
            //NSLog(@"num behaviors in range: %d", numBehaviorsInRange);
            meanVariance += powf(numBehaviorsInRange - averageBehavior, 2);
        }
        //NSLog(@"mean variance is: %f", meanVariance);
        totalStdDev += sqrtf(meanVariance / [currentUser.sessionLength intValue]);
        
        NSLog(@"the average behavior: %f", averageBehavior);
        NSLog(@"std dev: %f", totalStdDev);
        
    }
    
    //float stdDev = sqrtf(meanVariance / 20.0f);
    float stdDev = totalStdDev / theUsers.count;
    return stdDev;
}

-(float)stdDevReinforcerForUsers:(NSArray *)theUsers {
    
    NSArray *reinforcerForUsers = [self reinforcerOnlyForUsers:theUsers];
    // multiplied by 30 because the interval is 30 seconds
    float averageReinforcer = [self avgReinforcerForUsers:theUsers] * 30;
    
    float meanVariance = 0;
    
    for (int i = 0; i < 20; i++) {
        
        NSRange range = NSMakeRange(i * 30, 30);
        // have to devide by the number of users
        int numReinforcersInRange = [self numReinforcers:reinforcerForUsers inRange:range];
        meanVariance += pow(numReinforcersInRange - averageReinforcer, 2);
        
    }
    
    float stdDev = sqrtf(meanVariance / 20.0f);
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
