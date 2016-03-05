//
//  MAXBlockView.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 08/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAXBlockView;

@protocol MAXBlockViewDatasource <NSObject>

@required
-(NSInteger)numRowsInBlockView:(MAXBlockView*)theBlockView;
-(NSInteger)numColumnsInBlockView:(MAXBlockView*)theBlockView inRow:(NSUInteger)theRow;

@optional


-(UIColor*)colorForBlockInRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn;

-(UIView*)blockView:(UIView*)theView forRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn;

-(void)blocksView:(MAXBlockView*)theBlockView block:(UIView*)theBlock forRow:(NSUInteger)theRow forCol:(NSUInteger)theCol;

@end

@protocol MAXBlockViewDelegate <NSObject>

-(CGFloat)heightForRow:(NSUInteger)theRow;
-(CGFloat)heightForHorizontalSepratorForRow:(NSUInteger)theRow;
-(CGFloat)widthForVerticalSeparatorForRow:(NSUInteger)theRow;
//-(CGFloat)widthForVerticalSepratorForRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn;


-(UIColor*)colorForHorizontalSepratorForRow:(NSUInteger)theRow;
-(UIColor*)colorForVerticalSeparatorForRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn;

@end

@interface MAXBlockView : UIView

@property (nonatomic, strong) id <MAXBlockViewDatasource> datasource;
@property (nonatomic, strong) id <MAXBlockViewDelegate> delegate;

+(instancetype)blockViewWithFrame:(CGRect)theFrame;
+(instancetype)blockView;

-(void)reloadData;

@end
