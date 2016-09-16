//
//  OperantConditioningPostreinforcementDataMockTest.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 16/09/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MAXRandomUser.h"
#import "MAXBehavior.h"
#import "MAXReinforcer.h"
#import "MAXOperantCondDataMan.h"

static MAXOperantCondDataMan *_dataMan;

@interface OperantConditioningPostreinforcementDataMockTest : XCTestCase

@end

@implementation OperantConditioningPostreinforcementDataMockTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _dataMan = [[MAXOperantCondDataMan alloc] initWithBundle:[NSBundle bundleForClass:[self class]] behaviorFile:@"BehaviorPostreinforcementTest" behaviorFileType:@"json" reinforcementFile:@"ReinforcerPostreinforcementTest" reinforcementFileType:@"json" userFile:@"RandomUserPostreinforcementTest" userFileType:@"json"];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUserOneAvgPostreinforcementPause {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    MAXRandomUser *userOne = [[_dataMan usersWithIds:@[@"1"]] firstObject];
    
    double postreinforcementPause = [_dataMan avgPostreinforcementTimeForUsers: @[userOne]];
    XCTAssertTrue( postreinforcementPause == 3 );
}

-(void)testUserOneMaxAvgPostreinforcementPause {
    
    MAXRandomUser *userOne = [[_dataMan usersWithIds:@[@"1"]] firstObject];
    
    double maxAvgPostreinforcementPause = [_dataMan avgMaxPostreinforcementTimeForUsers: @[userOne]];
    XCTAssertTrue( maxAvgPostreinforcementPause == 4 );
    
}

-(void)testUserOneMinAvgPostreinforcementPause {
    
    MAXRandomUser *userOne = [[_dataMan usersWithIds: @[@"1"]] firstObject];
    
    double minAvgPostreinforcementPause = [_dataMan avgMinPostreinforcementTimeForUsers: @[userOne]];
    XCTAssertTrue( minAvgPostreinforcementPause == 2);
    
}

-(void)testUserOneStdDevPostreinforcementPause {
    
    MAXRandomUser *userOne = [[_dataMan usersWithIds: @[@"1"]] firstObject];
    
    double stdDevPostreinforcementPause = [_dataMan stdDevPostreinforcementTimeForUsers: @[userOne]];
    NSString *stdDevString = [NSString stringWithFormat:@"%.4f", stdDevPostreinforcementPause];
    XCTAssertEqualObjects(stdDevString, @"0.7071");
    
}

-(void)testFIUsersAvgPostreinforcementPause {
    
    NSArray <MAXRandomUser *> *FIUSers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
    
    double avgPostreinforcementPause = [_dataMan avgPostreinforcementTimeForUsers: FIUSers];
    
    XCTAssertTrue(avgPostreinforcementPause == 2.5);
    
}

-(void)testFIUsersAvgMaxPostreinforcementPause {
    
    NSArray <MAXRandomUser *> *FIUsers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
    
    double avgMaxPostreinforcementPause = [_dataMan avgMaxPostreinforcementTimeForUsers: FIUsers];
    
    XCTAssertTrue(avgMaxPostreinforcementPause == 3.5);
    
}

-(void)testFIUsersAvgMinPostreinforcementPause {
    
    NSArray <MAXRandomUser *> *FIUsers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
    
    double avgMinPostreinforcementPause = [_dataMan avgMinPostreinforcementTimeForUsers: FIUsers];
    
    XCTAssertTrue(avgMinPostreinforcementPause == 1.5);
    
}

-(void)testFIUsersStdDevPostreinforcementPause {
    
    NSArray <MAXRandomUser *> *FIUSers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
    
    double stdDevPostreinforcementPause = [_dataMan stdDevPostreinforcementTimeForUsers: FIUSers];
    NSString *stdDevString = [NSString stringWithFormat:@"%.4f", stdDevPostreinforcementPause];
    
    XCTAssertEqualObjects(stdDevString, @"0.7618");
    
}

-(void)testFIUsersStdDevMaxPostreinforcementPause {
    
    NSArray <MAXRandomUser *> *FIUsers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
    
    double stdDevMaxPostreinforcementPause = [_dataMan stdDevMaxPostreinforcementTimeForUsers: FIUsers];
    NSString *stdDevString = [NSString stringWithFormat:@"%.4f", stdDevMaxPostreinforcementPause];
    
    XCTAssertEqualObjects(stdDevString, @"0.5000");
    
}

-(void)testFIUsersStdDevMinPostreinforcementPause {
    
    NSArray <MAXRandomUser *> *FIUsers = [_dataMan usersWithReinforcementSchedule: kFISchedule];
    
    double stdDevMinPostreinforcementPause = [_dataMan stdDevMinPostreinforcemenTimeForUsers: FIUsers];
    NSString *stdDevString = [NSString stringWithFormat:@"%.4f", stdDevMinPostreinforcementPause];
    
    XCTAssertEqualObjects(stdDevString, @"0.5000");
    
}


@end
