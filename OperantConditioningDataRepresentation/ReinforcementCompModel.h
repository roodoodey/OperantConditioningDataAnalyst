//
//  ReinforcementCompModel.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 10/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MAXOperantCondDataMan.h"

@interface ReinforcementCompModel : NSObject

-(id)initWithUsers:(NSArray*)theUsers dataMan:(MAXOperantCondDataMan*)theDataMan;

#pragma mark - Charts 

-(NSInteger)numLines;
-(NSUInteger)numVerticalValuesForLine:(NSUInteger)theLineIndex;
-(CGFloat)verticalValueForHorizontalIndex:(NSUInteger)theHorizIndex forLineIndex:(NSUInteger)theLindeIndex;

-(UIColor*)colorForLineAtIndex:(NSUInteger)theLineIndex;

#pragma mark - Blocks

-(NSString*)stringTitleForRow:(NSUInteger)theRow col:(NSUInteger)theCol;
-(NSString*)stringForRow:(NSUInteger)theRow col:(NSUInteger)theCol;

-(NSString*)avgBehaviorForLine:(NSUInteger)theLindeIndex;
-(NSString*)avgReinforcerForLine:(NSUInteger)theLineIndex;


@end
