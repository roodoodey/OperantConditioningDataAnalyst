//
//  MAXBlockView.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 08/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "MAXBlockView.h"

@interface MAXBlockView () {
    
    NSMutableArray *_blockViews;
    NSMutableArray *_blocksHorizSeparators;
    NSMutableArray *_blockVertSeparators;
    
}

@end

@implementation MAXBlockView

#pragma mark - Class Initializers

+(instancetype)blockView {
    return [[self alloc] init];
}

+(instancetype)blockViewWithFrame:(CGRect)theFrame {
    return [[self alloc] initWithFrame:theFrame];
}

#pragma mark - Initializers

-(id)init {
    return [self initWithFrame:CGRectZero];
}

-(id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.datasource = nil;
        self.delegate = nil;
        
        _blockViews = [NSMutableArray array];
        _blocksHorizSeparators = [NSMutableArray array];
        _blockVertSeparators = [NSMutableArray array];
        
        [self reloadData];
        
    }
    
    return self;
}


#pragma mark - Reload Data Logic

-(void)reloadData {
    
    [self removeViews];
    
    if(self.datasource != nil && self.delegate != nil) {
        
        float yPos = 0.0f;
        
        for (NSUInteger row = 0; row < [self.datasource numRowsInBlockView:self]; row++) {
            
            [_blocksHorizSeparators addObject:[self createHorizontalSeparatorForRow:row yPos:&yPos]];
            [_blockViews addObject:[self viewsForRow:row yPos:&yPos]];
            
        }
        
        [_blocksHorizSeparators addObject:[self createHorizontalSeparatorForRow:[self.datasource numRowsInBlockView:self] yPos:&yPos]];
        
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), yPos);
        
        [self viewsToPopulate:_blockViews];
    }
    
}


#pragma mark - Send the views for population

-(void)viewsToPopulate:(NSArray*)theBlockViews {
    
    if ([self.datasource respondsToSelector:@selector(blocksView:block:forRow:forCol:)]) {
        
        for (int row = 0; row < theBlockViews.count; row++) {
            NSArray *colViews = [theBlockViews objectAtIndex:row];
            
            for (int col = 0; col < colViews.count; col++) {
                UIView *theBlockView = [colViews objectAtIndex:col];
                [self.datasource blocksView:self block:theBlockView forRow:row forCol:col];
            }
            
        }
    }
    
}

#pragma mark - Removing The Views

-(void)removeViews {
    
    for (NSArray *viewsForBlock in _blockViews) {
        for (UIView *colView in viewsForBlock) {
            [colView removeFromSuperview];
        }
    }
    
    for (UIView *currentView in _blocksHorizSeparators) {
        [currentView removeFromSuperview];
    }
    
    for (UIView *currentView in _blockVertSeparators) {
        [currentView removeFromSuperview];
    }
    
    [_blockViews removeAllObjects];
    [_blocksHorizSeparators removeAllObjects];
    [_blocksHorizSeparators removeAllObjects];
    
    
    
}

#pragma mark - Creating The Views

-(NSArray*)viewsForRow:(NSUInteger)theRow yPos:(float *)theYPos {
    
    NSMutableArray *theViews = [NSMutableArray array];
    
    int numColumns = [self.datasource numColumnsInBlockView:self inRow:theRow];
    
    float separatorWidth = [self.delegate widthForVerticalSeparatorForRow:theRow];
    
    float rowHeight = [self.delegate heightForRow:theRow];
    float colWidth = (CGRectGetWidth(self.frame) - (numColumns - 1) * separatorWidth) / (float)[self.datasource numColumnsInBlockView:self inRow:theRow];
    
    float xPos = 0;
    
    for (NSUInteger col = 0; col < [self.datasource numColumnsInBlockView:self inRow:theRow]; col++) {
        
        UIView *currentView = [self createViewForRow:theRow forColumn:col yPosition:*theYPos xPosition:xPos height:rowHeight width:colWidth];
        [theViews addObject:currentView];
        
        xPos += colWidth;
        
        // Add the vertical separators
        if (col < [self.datasource numColumnsInBlockView:self inRow:theRow] - 1) {
            
            UIView *separator = [self createVerticalSeparatorForRow:theRow forColumn:col rowHeight:rowHeight sepWidth:separatorWidth yPos:theYPos xPos:&xPos];
            [_blockVertSeparators addObject:separator];
            
            xPos += separatorWidth;
            
        }
        
    }
    
    
    *theYPos += rowHeight;
    
    return theViews;
}

-(UIView *)createViewForRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn yPosition:(float)theYPos xPosition:(float)theXPos height:(float)theHeight width:(float)theWidth {
    
    
    UIView *columnView = [[UIView alloc] initWithFrame:CGRectMake(theXPos, theYPos, theWidth, theHeight)];
    [self addSubview:columnView];
    
    if ([self.datasource respondsToSelector:@selector(colorForBlockInRow:forColumn:)]) {
        columnView.backgroundColor = [self.datasource colorForBlockInRow:theRow forColumn:theColumn];
    }
    
    return columnView;
}

#pragma mark - Horizontal and Vertical Separator Creations

-(UIView*)createVerticalSeparatorForRow:(NSInteger)theRow forColumn:(NSInteger)theColumn rowHeight:(float)theRowHeight sepWidth:(float)theSepWidth yPos:(float*)theYPos xPos:(float*)xPos {
    
    UIView *verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(*xPos, *theYPos, theSepWidth, theRowHeight)];
    [self addSubview:verticalSeparator];
    
    if ([self.delegate respondsToSelector:@selector(colorForVerticalSeparatorForRow:forColumn:)]) {
        verticalSeparator.backgroundColor = [self.delegate colorForVerticalSeparatorForRow:theRow forColumn:theColumn];
    }
        
    return verticalSeparator;
}

-(UIView*)createHorizontalSeparatorForRow:(NSUInteger)theRow yPos:(float*)theYPos {
    
    float heightForSeparator = [self.delegate heightForHorizontalSepratorForRow:theRow];
    
    UIView *horizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, *theYPos, CGRectGetWidth(self.frame), heightForSeparator)];
    [self addSubview:horizontalSeparator];
    
    if ([self.delegate respondsToSelector:@selector(colorForHorizontalSepratorForRow:)]) {
        horizontalSeparator.backgroundColor = [self.delegate colorForHorizontalSepratorForRow:theRow];
    }
    
    *theYPos += heightForSeparator;
    
    return horizontalSeparator;
}

@end
