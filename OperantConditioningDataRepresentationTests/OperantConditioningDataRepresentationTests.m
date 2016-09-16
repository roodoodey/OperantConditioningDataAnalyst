//
//  OperantConditioningDataRepresentationTests.m
//  OperantConditioningDataRepresentationTests
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MNFJsonAdapter.h"
#import "MAXBehavior.h"
#import "MAXRandomUser.h"
#import "MAXReinforcer.h"
#import "MAXOperantCondDataMan.h"

@interface OperantConditioningDataRepresentationTests : XCTestCase

@end

static NSArray *_reinforcers;
static NSArray *_behaviors;
static NSArray *_randomUsers;
static MAXOperantCondDataMan *_dataMan;

@implementation OperantConditioningDataRepresentationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (_dataMan == nil) {
        _dataMan = [[MAXOperantCondDataMan alloc] init];
    }
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testDataManSetup {
    
    XCTAssertTrue(_dataMan.allUsers.count == 30);
    XCTAssertTrue(_dataMan.reinforcers.count == 1081);
    XCTAssertTrue(_dataMan.behavior.count == 34873);
    XCTAssertTrue(_dataMan.users.count == 28);
    
}

-(void)testFISchedule {
    
    NSArray *FIUsers = [_dataMan usersWithReinforcementSchedule:kFISchedule];
    XCTAssertTrue(FIUsers.count == 8);
    
    NSArray *behaviorFI = [_dataMan behaviorForUsersByUser:FIUsers];
    NSArray *reinforcerFI = [_dataMan reinforcerForUsersByUsers:FIUsers];
    
    [self validateUsersBehaviorArray:behaviorFI users:FIUsers];
    [self validateUsersReinforcerArray:reinforcerFI users:FIUsers];
    
    float avgBehavior = [_dataMan avgBehaviorForUsers:FIUsers];
    NSLog(@"FI avg. behavior: %f", avgBehavior * 30);
    
    float avgReinforcer = [_dataMan avgReinforcerForUsers:FIUsers];
    NSLog(@"FI avg. reinforcer: %f", avgReinforcer * 30);
    
    float avgTime = [_dataMan avgTimeForUsers:FIUsers];
    NSLog(@"FI avg. time: %f", avgTime);
    
    float stdDevBehavior = [_dataMan stdDevBehaviorForUsers:FIUsers];
    NSLog(@"FI std dev behavior: %f", stdDevBehavior * 30);
    
    float stdDevReinforcer = [_dataMan stdDevReinforcerForUsers:FIUsers];
    NSLog(@"FI std dev reinforcer: %f", stdDevReinforcer);
    
    float stdTime = [_dataMan stdDevTimeForUsers:FIUsers];
    NSLog(@"FI std dev time: %f", stdTime);
    
    int numBehaviorsForUser = (int)[_dataMan behaviorOnlyForUsers: FIUsers].count;
    int numReinforcersForUser = (int)[_dataMan reinforcerOnlyForUsers: FIUsers].count;
    NSLog(@"behavior FI: %d, reinforcers FI: %d, num users: %d", numBehaviorsForUser, numReinforcersForUser, (int)FIUsers.count);
    NSLog(@"avg behavior FI: %f, avg reinforcers FI: %f", numBehaviorsForUser / (float)FIUsers.count, numReinforcersForUser / (float)FIUsers.count);
}


-(void)testVISchedule {
    
    NSArray *VIUsers = [_dataMan usersWithReinforcementSchedule:kVISchedule];
    
    XCTAssertTrue(VIUsers.count == 7);
    
    NSArray *behaviorVI = [_dataMan behaviorForUsersByUser:VIUsers];
    NSArray *reinforcerVI = [_dataMan reinforcerForUsersByUsers:VIUsers];
    
    [self validateUsersBehaviorArray:behaviorVI users:VIUsers];
    [self validateUsersReinforcerArray:reinforcerVI users:VIUsers];
    
    float avgBehavior = [_dataMan avgBehaviorForUsers:VIUsers];
    NSLog(@"VI avg. behavior: %f", avgBehavior * 30);
    
    float avgReinforcer = [_dataMan avgReinforcerForUsers:VIUsers];
    NSLog(@"VI avg. reinforcer: %f", avgReinforcer * 30);
    
    float avgTime = [_dataMan avgTimeForUsers:VIUsers];
    NSLog(@"VI avg. time: %f", avgTime);
    
    float stdDevBehavior = [_dataMan stdDevBehaviorForUsers:VIUsers];
    NSLog(@"VI std dev behavior: %f", stdDevBehavior);
    
    float stdDevReinforcer = [_dataMan stdDevReinforcerForUsers:VIUsers];
    NSLog(@"VI std dev reinforcer: %f", stdDevReinforcer);
    
    float stdTime = [_dataMan stdDevTimeForUsers:VIUsers];
    NSLog(@"VI std dev time: %f", stdTime);
    
    int numBehaviorsForUser = (int)[_dataMan behaviorOnlyForUsers: VIUsers].count;
    int numReinforcersForUser = (int)[_dataMan reinforcerOnlyForUsers: VIUsers].count;
    NSLog(@"behavior VI: %d, reinforcers VI: %d, num users: %d", numBehaviorsForUser, numReinforcersForUser, (int)VIUsers.count);
    NSLog(@"avg behavior VI: %f, avg reinforcers VI: %f", numBehaviorsForUser / (float)VIUsers.count, numReinforcersForUser / (float)VIUsers.count);
    
}

-(void)testFRSchedule {
    
    NSArray *FRUsers = [_dataMan usersWithReinforcementSchedule:kFRSchedule];
    XCTAssertTrue(FRUsers.count == 7);
    
    NSArray *behaviorFR = [_dataMan behaviorForUsersByUser:FRUsers];
    NSArray *reinforcerFR = [_dataMan reinforcerForUsersByUsers:FRUsers];
    
    [self validateUsersBehaviorArray:behaviorFR users:FRUsers];
    [self validateUsersReinforcerArray:reinforcerFR users:FRUsers];
    
    float avgBehavior = [_dataMan avgBehaviorForUsers:FRUsers];
    NSLog(@"FR avg. behavior: %f", avgBehavior * 30);
    
    float avgReinforcer = [_dataMan avgReinforcerForUsers:FRUsers];
    NSLog(@"FR avg reinforcer: %f", avgReinforcer * 30);
    
    float avgTime = [_dataMan avgTimeForUsers:FRUsers];
    NSLog(@"FR avg. time: %f", avgTime);
    
    float stdDevBehavior = [_dataMan stdDevBehaviorForUsers:FRUsers];
    NSLog(@"FR std dev behavior: %f", stdDevBehavior);
    
    float stdDevReinforcer = [_dataMan stdDevReinforcerForUsers:FRUsers];
    NSLog(@"FR std dev reinforcer: %f", stdDevReinforcer);
    
    float stdTime = [_dataMan stdDevTimeForUsers:FRUsers];
    NSLog(@"FR std dev time: %f", stdTime);
   
    int numBehaviorsForUser = (int)[_dataMan behaviorOnlyForUsers: FRUsers].count;
    int numReinforcersForUser = (int)[_dataMan reinforcerOnlyForUsers: FRUsers].count;
    NSLog(@"behavior FR: %d, reinforcers FR: %d, num users: %d", numBehaviorsForUser, numReinforcersForUser, (int)FRUsers.count);
    NSLog(@"avg behavior FR: %f, avg reinforcers FR: %f", numBehaviorsForUser / (float)FRUsers.count, numReinforcersForUser / (float)FRUsers.count);
}

-(void)testVRSchedule {
    
    NSArray *VRUsers = [_dataMan usersWithReinforcementSchedule:kVRSchedule];
    XCTAssertTrue(VRUsers.count == 6);
    
    NSArray *behaviorVR = [_dataMan behaviorForUsersByUser:VRUsers];
    NSArray *reinforcerVR = [_dataMan reinforcerForUsersByUsers:VRUsers];
    
    [self validateUsersBehaviorArray:behaviorVR users:VRUsers];
    [self validateUsersReinforcerArray:reinforcerVR users:VRUsers];
    
    float avgBehavior = [_dataMan avgBehaviorForUsers:VRUsers];
    NSLog(@"VR avg. behavior: %f", avgBehavior * 30);
    
    float avgReinforcer = [_dataMan avgReinforcerForUsers:VRUsers];
    NSLog(@"VR avg. reinforcer: %f", avgReinforcer * 30);
    
    float avgTime = [_dataMan avgTimeForUsers:VRUsers];
    NSLog(@"VR avg. time: %f", avgTime);
    
    float stdDevBehavior = [_dataMan stdDevBehaviorForUsers:VRUsers];
    NSLog(@"VR std dev behavior: %f", stdDevBehavior);
    
    float stdDevReinforcer = [_dataMan stdDevReinforcerForUsers:VRUsers];
    NSLog(@"VR std dev reinforcer: %f", stdDevReinforcer);
    
    float stdTime = [_dataMan stdDevTimeForUsers:VRUsers];
    NSLog(@"VR std dev time: %f", stdTime);
    
    int numBehaviorsForUsers = (int)[_dataMan behaviorOnlyForUsers: VRUsers].count;
    int numReinforcersForUsers = (int)[_dataMan reinforcerOnlyForUsers: VRUsers].count;
    NSLog(@"behavior VR: %d, reinforcer VR: %d, num users: %d", numBehaviorsForUsers, numReinforcersForUsers, (int)VRUsers.count);
    NSLog(@"avg behavior VR: %f, avg reinforcers VR: %f", (float)numBehaviorsForUsers / (float)VRUsers.count, numReinforcersForUsers / (float)VRUsers.count);
    
}

-(int)numBehaviorUnderElapsedTime:(float)theElapsedTime inBehavior:(NSArray*)theBehavior {
    
    int count = 0;
    for (MAXBehavior *behavior in theBehavior) {
        if ([behavior.elapsedTime floatValue] < theElapsedTime) {
            count++;
        }
    }
    return count;
}


#pragma mark - Helpers

-(void)validateUsersReinforcerArray:(NSArray*)theUsersReinforcer users:(NSArray*)theUsers {
    for (NSArray *userReinforcer in theUsersReinforcer) {
        for (MAXReinforcer *reinforcer in userReinforcer) {
            XCTAssertTrue([self reinforcer:reinforcer inUsers:theUsers] == YES);
        }
    }
}

-(void)validateUsersBehaviorArray:(NSArray*)theUsersBehavior users:(NSArray*)theUsers {
    
    for (NSArray *userBehavior in theUsersBehavior) {
        for (MAXBehavior *behavior in userBehavior) {
            XCTAssertTrue([self behavior:behavior inUsers:theUsers] == YES);
        }
    }
    
}

-(BOOL)reinforcer:(MAXReinforcer*)theReinforcer inUsers:(NSArray*)theUsers {
    for (MAXRandomUser *randUser in theUsers) {
        if ([randUser.objectId isEqualToString:theReinforcer.userId] == YES) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)behavior:(MAXBehavior*)theBehavior inUsers:(NSArray*)theUSers {
    for (MAXRandomUser *randUser in theUSers) {
        if ([randUser.objectId isEqualToString:theBehavior.userId] == YES) {
            return YES;
        }
    }
    
    return NO;
}

@end
