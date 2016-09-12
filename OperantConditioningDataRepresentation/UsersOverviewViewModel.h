//
//  UsersOverviewViewModel.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 04/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RandomUser;
@class MAXRandomUser;

@interface UsersOverviewViewModel : NSObject

-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSString*)userIdAtIndexPath:(NSIndexPath*)indexPath;
-(MAXRandomUser*)userAtIndexPath:(NSIndexPath*)indexPath;

-(BOOL)isUserExcludedAtIndexPath:(NSIndexPath*)indexPath;

-(void)excludeOrAddUserDataAtIndexPath:(NSIndexPath*)indexPath withCompletion:(void (^)(BOOL excluded))block;

@end
