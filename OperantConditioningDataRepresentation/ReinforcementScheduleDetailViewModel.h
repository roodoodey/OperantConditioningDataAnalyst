//
//  ReinforcementScheduleDetailViewModel.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 15/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MAXOperantCondDataMan.h"

@interface ReinforcementScheduleDetailViewModel : NSObject

-(id)initWithReinforcementSchedule:(NSNumber*)reinforcementSchedule dataMan:(MAXOperantCondDataMan*)theDataMan;

-(NSString*)reinforcementTitleForNum:(NSNumber*)reinforcementNum;

#pragma mark - Reinforcer Data

-(NSUInteger)numReinforcersForLineAtIndex:(NSInteger)theIndex;
-(CGFloat)reinforcerValueAtX:(NSInteger)xIndex lineIndex:(NSInteger)theLine;

#pragma mark - Block Data

-(NSString*)titleForRow:(NSInteger)theRow col:(NSInteger)theCol;
-(NSString*)dataTitleForRow:(NSInteger)theRow col:(NSInteger)theCol;


#pragma mark - Chart Data

-(CGFloat)maxYValue;
-(NSString*)maxXValueString;
-(NSString*)maxYValueString;

-(NSUInteger)numLines;
-(UIColor*)colorForLineAtIndex:(NSInteger)theIndex;
-(NSUInteger)numValuesForLineAtIndex:(NSUInteger)theIndex;
-(CGFloat)valueForLineAtIndex:(NSUInteger)theLineIndex withHorizontalIndex:(NSUInteger)theHorizontalIndex;


@end
