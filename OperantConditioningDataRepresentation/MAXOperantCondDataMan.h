//
//  MAXOperantCondDataMan.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 05/03/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class MAXBehavior;
@class MAXReinforcer;
@class MAXRandomUser;

@interface MAXOperantCondDataMan : NSObject

-(id)initWithBundle:(NSBundle*)theBundle;
-(id)initWithBundle:(NSBundle *)theBundle behaviorFile:(NSString*)theBehaviorFile behaviorFileType:(NSString*)theBehaviorFileType reinforcementFile:(NSString*)theReinforcementFile reinforcementFileType:(NSString*)theReinforcementFileType userFile:(NSString*)theUserFile userFileType:(NSString*)theUserFileType;

@property (nonatomic, strong) NSArray *behavior;
@property (nonatomic, strong) NSArray *correctBehavior;
@property (nonatomic, strong) NSArray *reinforcers;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *allUsers;


#pragma mark - Data Getters


-(NSArray <MAXRandomUser *> *)usersWithReinforcementSchedule:(ReinforcementSchedule)theReinforcementSchedule;
-(NSArray <MAXRandomUser *> *)usersWithIds:(NSArray <NSString *> *)theIds;

-(NSArray <NSArray <MAXBehavior *> *> *)behaviorForUsersByUser:(NSArray*)theUsers;
-(NSArray <NSArray <MAXReinforcer *> *> *)reinforcerForUsersByUsers:(NSArray*)theUsers;


-(NSArray <MAXBehavior *> *)behaviorOnlyForUsers:(NSArray*)theUsers;
-(NSArray <MAXReinforcer *> *)reinforcerOnlyForUsers:(NSArray*)theUsers;


#pragma mark - Data Information

-(double)avgPostreinforcementTimeForUsers:(NSArray *)theUsers;
-(double)stdDevPostreinforcementTimeForUsers:(NSArray *)theUsers;
-(double)avgMinPostreinforcementTimeForUsers:(NSArray *)theUsers;
-(double)avgMaxPostreinforcementTimeForUsers:(NSArray *)theUsers;

-(float)avgBehaviorForUsers:(NSArray*)theUsers;
-(float)avgReinforcerForUsers:(NSArray*)theUsers;
-(float)avgTimeForUsers:(NSArray*)theUsers;

-(float)stdDevBehaviorForUsers:(NSArray*)theUsers;
-(float)stdDevReinforcerForUsers:(NSArray*)theUsers;
-(float)stdDevTimeForUsers:(NSArray*)theUsers;

-(int)numBehaviors:(NSArray*)theBehavior inRange:(NSRange)theRange;
-(int)numReinforcers:(NSArray*)theReinforcer inRange:(NSRange)theRange;

@end
