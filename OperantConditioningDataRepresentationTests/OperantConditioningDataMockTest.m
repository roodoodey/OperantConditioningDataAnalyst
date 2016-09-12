//
//  OperantConditioningDataMockTest.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 06/03/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MAXBehavior.h"
#import "MAXReinforcer.h"
#import "MAXRandomUser.h"
#import "MAXOperantCondDataMan.h"

@interface OperantConditioningDataMockTest : XCTestCase

@end

static MAXOperantCondDataMan *_dataMan;

@implementation OperantConditioningDataMockTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (_dataMan == nil) {
        _dataMan = [[MAXOperantCondDataMan alloc] initWithBundle:[NSBundle bundleForClass:[self class]] behaviorFile:@"BehaviorTest" behaviorFileType:@"json" reinforcementFile:@"ReinforcerTest" reinforcementFileType:@"json" userFile:@"RandomUserTest" userFileType:@"json"];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testDataMan {
    
    XCTAssertTrue(_dataMan.allUsers.count == 3);
    XCTAssertTrue(_dataMan.users.count == 3);
    XCTAssertTrue(_dataMan.behavior.count == 93);
    XCTAssertTrue(_dataMan.correctBehavior.count == 90);
    
}

-(void)testFISchedule {
    
    NSArray *FIUsers = [_dataMan usersWithReinforcementSchedule:kFISchedule];
    
    XCTAssertTrue(FIUsers.count == 2);
    
    NSArray *FIBehaviors = [_dataMan behaviorForUsersByUser:FIUsers];
    XCTAssertTrue(FIBehaviors.count == 2);
    
    [self validateUsersBehaviorArray:FIBehaviors users:FIUsers];
    
    NSArray *FIBehaviorUserOne = [FIBehaviors objectAtIndex:0];
    NSArray *FIBehaviorUserTwo = [FIBehaviors objectAtIndex:1];
    
    XCTAssertTrue(FIBehaviorUserOne.count == 30);
    XCTAssertTrue(FIBehaviorUserTwo.count == 30);
    
    NSArray *FIReinforcers = [_dataMan reinforcerForUsersByUsers:FIUsers];
    
    [self validateUsersReinforcerArray:FIReinforcers users:FIUsers];
    
    NSArray *FIReinforcersUserOne = [FIReinforcers objectAtIndex:0];
    NSArray *FIReinforcersUserTwo = [FIReinforcers objectAtIndex:1];
    
    XCTAssertTrue(FIReinforcersUserOne.count == 8);
    XCTAssertTrue(FIReinforcersUserTwo.count == 7);
    
    float avgBehavior = [_dataMan avgBehaviorForUsers:FIUsers];
    XCTAssertTrue(avgBehavior == 0.25);
    
    float avgReinforcer = [_dataMan avgReinforcerForUsers:FIUsers];
    XCTAssertTrue(avgReinforcer == 0.0625);
    
}

-(void)testVISchedule {
    
    NSArray *VIUsers = [_dataMan usersWithReinforcementSchedule:kVISchedule];
    
    XCTAssertTrue(VIUsers.count == 1);
    
    NSArray *VIBehavior = [_dataMan behaviorForUsersByUser:VIUsers];
    NSArray *behaviorsUserOne = [VIBehavior objectAtIndex:0];
    XCTAssertTrue(behaviorsUserOne.count == 30);
    
    NSArray *VIReinforcer = [_dataMan reinforcerForUsersByUsers:VIUsers];
    NSArray *reinforcersUserOne = [VIReinforcer objectAtIndex:0];
    XCTAssertTrue(reinforcersUserOne.count == 15);
    
    [self validateUsersBehaviorArray:VIBehavior users:VIUsers];
    [self validateUsersReinforcerArray:VIReinforcer users:VIUsers];
    
    float avgBehavior = [_dataMan avgBehaviorForUsers:VIUsers];
    XCTAssertTrue(avgBehavior == 0.25);
    
    float avgReinforcer = [_dataMan avgReinforcerForUsers:VIUsers];
    XCTAssertTrue(avgReinforcer == 0.125);
    
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
