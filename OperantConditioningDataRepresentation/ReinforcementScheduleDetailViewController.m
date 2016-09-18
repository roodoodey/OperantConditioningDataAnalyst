//
//  ReinforcementScheduleDetailViewController.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 15/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ReinforcementScheduleDetailViewController.h"
#import "ReinforcementScheduleDetailViewModel.h"
#import "MAXBlockView.h"
#import "JBLineChartView.h"
#import "UIColor+Chameleon.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "MBProgressHUD.h"

#import "MAXPagingScrollView.h"
#import "MAXLineChartView.h"

@interface ReinforcementScheduleDetailViewController () <MAXBlockViewDelegate, MAXBlockViewDatasource, JBLineChartViewDataSource, JBLineChartViewDelegate, MAXLineChartDelegate, MAXLineChartDataSource> {
    
    NSArray *_scheduleUsers;
    
    ReinforcementScheduleDetailViewModel *_viewModel;
    JBLineChartView *_lineChart;
    UIScrollView *_scrollView;
    UIScrollView *_bigChartScrollView;
    MAXLineChartView *_bigLineChart;
}

@end

@implementation ReinforcementScheduleDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _viewModel = [[ReinforcementScheduleDetailViewModel alloc] initWithReinforcementSchedule:self.reinforcementSchedule dataMan:self.dataMan];
    
    
    // navigation bar
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    navBar.backgroundColor = [UIColor flatTealColor];
    [self.view addSubview:navBar];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 20, 80, CGRectGetHeight(navBar.frame) - 20);
    [backButton setTitleColor:[UIColor flatGreenColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor flatGreenColorDark] forState:UIControlStateHighlighted];
    [backButton setTitle:@"< Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont maxwellBoldWithSize:19.0];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:backButton];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 80, 20, 160, CGRectGetHeight(navBar.frame) - 20)];
    title.textColor = [UIColor flatWhiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = [_viewModel reinforcementTitleForNum:self.reinforcementSchedule];
    title.font = [UIFont maxwellBoldWithSize:19.0];
    [navBar addSubview:title];
    
    MAXPagingScrollView *pagingScrollView = [[MAXPagingScrollView alloc] initWithFrame: CGRectMake(0, CGRectGetHeight(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(navBar.frame))];
    
    [pagingScrollView MAXScrollViewNumPagesWithBlock:^ NSInteger {
       
        return 2;
    }];
    
    [pagingScrollView MAXScrollViewWithViewAtPageBlock:^(UIView *theView, NSInteger page) {
       
        if (page == 0) {
            [theView addSubview: [self p_createFirstScrollView]];
        }
        else if(page == 1) {
            [theView addSubview: [self p_createBigChart]];
        }
        
    }];
    
    [self.view addSubview: pagingScrollView];
    
    
}

#pragma mark - Create Views

-(UIScrollView *)p_createFirstScrollView {
    
    if (_scrollView == nil) {
        
        // containing scroll view
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
        [self.view addSubview:_scrollView];
        
        
        // chart
        _lineChart = [[JBLineChartView alloc] initWithFrame:CGRectMake(30, 40, CGRectGetWidth(self.view.frame) - 60, 240)];
        _lineChart.delegate = self;
        _lineChart.dataSource = self;
        [_lineChart setMinimumValue:0];
        [_lineChart setMaximumValue:[_viewModel maxYValue]];
        [_scrollView addSubview:_lineChart];
        
        UIView *yAxis = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_lineChart.frame) - 2, CGRectGetMinY(_lineChart.frame), 2, CGRectGetHeight(_lineChart.frame))];
        yAxis.backgroundColor = [UIColor flatSkyBlueColor];
        [_scrollView addSubview:yAxis];
        
        UIView *xAxis = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_lineChart.frame) - 2, CGRectGetMaxY(_lineChart.frame), CGRectGetWidth(_lineChart.frame) + 2, 2)];
        xAxis.backgroundColor = [UIColor flatSkyBlueColor];
        [_scrollView addSubview:xAxis];
        
        UILabel *chartXAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMaxY(_lineChart.frame), 180, 40)];
        chartXAxisLabel.textAlignment = NSTextAlignmentCenter;
        chartXAxisLabel.textColor = [UIColor flatSkyBlueColor];
        chartXAxisLabel.text = @"Time (s)";
        chartXAxisLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:chartXAxisLabel];
        
        UILabel *originLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_lineChart.frame) - 10, CGRectGetMaxY(_lineChart.frame), 20, 40)];
        originLabel.textAlignment = NSTextAlignmentCenter;
        originLabel.textColor = [UIColor flatSkyBlueColor];
        originLabel.text = @"0";
        originLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:originLabel];
        
        
        UILabel *maxValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lineChart.frame) - 20, CGRectGetMaxY(_lineChart.frame), 40, 40)];
        maxValueLabel.textAlignment = NSTextAlignmentCenter;
        maxValueLabel.textColor = [UIColor flatSkyBlueColor];
        maxValueLabel.text = [_viewModel maxXValueString];
        maxValueLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:maxValueLabel];
        
        
        UILabel *maxYValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_lineChart.frame) - 25, 40, 50, CGRectGetMinY(_lineChart.frame) - 64)];
        maxYValueLabel.textAlignment = NSTextAlignmentCenter;
        maxYValueLabel.textColor = [UIColor flatSkyBlueColor];
        maxYValueLabel.text = [_viewModel maxYValueString];
        maxYValueLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:maxYValueLabel];
        
        
        MAXBlockView *blockView = [[MAXBlockView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lineChart.frame) + 40, CGRectGetWidth(self.view.frame), 600)];
        blockView.delegate = self;
        blockView.datasource = self;
        [blockView reloadData];
        [_scrollView addSubview:blockView];
        
        _scrollView.contentSize = CGSizeMake( CGRectGetWidth(self.view.frame), CGRectGetMaxY(blockView.frame));
        
        [_lineChart reloadData];
        
    }
    
    return _scrollView;
}

-(UIScrollView *)p_createBigChart {
    
    if (_bigChartScrollView == nil) {
        
        _bigChartScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
        
        [self.view addSubview: _bigChartScrollView];
        
        _bigLineChart = [[MAXLineChartView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetHeight(self.view.frame) - 64, CGRectGetWidth(self.view.frame))];
        _bigLineChart.delegate = self;
        _bigLineChart.datasource = self;
        [_bigLineChart reloadData];
        _bigLineChart.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
        _bigLineChart.frame = CGRectMake(0, 0, CGRectGetWidth(_bigLineChart.frame), CGRectGetHeight(_bigLineChart.frame));
        
        
        [_bigChartScrollView addSubview: _bigLineChart];
        
        
    }
    
    return _bigChartScrollView;
}

#pragma mark - MAX Cumulative Line Chart

-(NSUInteger)MAXNumberOfLinesForChart:(MAXLineChartView *)theChartView {
    
    return [_viewModel numLines];
}

-(NSUInteger)MAXLineChart:(MAXLineChartView *)theChartView numberOfXValuesForLine:(NSUInteger)theLine {
    
    return [_viewModel numValuesForLineAtIndex: theLine];
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView YValueAtX:(NSUInteger)theX line:(NSUInteger)theLine {
    
    double value = [_viewModel valueForLineAtIndex: theLine withHorizontalIndex: theX];
    
    return value;
}

-(double)MAXhighestYValueForLineChart:(MAXLineChartView *)theLineChart {
    
    return [_viewModel maxYValue];
}

-(double)MAXHighestXValueForLineChart:(MAXLineChartView *)theLineChart {
    
    return [_viewModel maxXValue];
}

-(CGFloat)MAXLineChart:(MAXLineChartView *)TheLineChart widthForLine:(NSUInteger)theLine {
    
    return 2.0;
}

-(UIColor *)MAXLineChart:(MAXLineChartView *)theLineChart strokeColorForLine:(NSUInteger)theLine {
    
    return [_viewModel colorForLineAtIndex: theLine];
}

-(UIColor *)MAXLineChartColorsForBordersForChart:(MAXLineChartView *)theLineChart {
    
    return [UIColor flatBlackColor];
}

-(CGFloat)MAXLineChartLeftBorderWidthForChart:(MAXLineChartView *)theLineChart {
    
    return 3.0;
}

-(CGFloat)MAXLineChartLowerBorderHeightForChart:(MAXLineChartView *)theLineChart {
    
    return 3.0;
}

#pragma mark - Left Border Decoration Views

-(NSUInteger)MAXLineChartNumberOfDecorationViewsForLeftBorder:(MAXLineChartView *)theLineChart {
    
    return 5;
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView yValueForLeftBorderDecorationViewAtIndex:(NSUInteger)theIndex {
    
    double highestValue = [self MAXhighestYValueForLineChart: theChartView];
    
    return theIndex * highestValue / ([self MAXLineChartNumberOfDecorationViewsForLeftBorder: theChartView] - 1);
}

-(UIView *)MAXLineChart:(MAXLineChartView *)theChartView leftBorderDecorationViewAxisCenterPoint:(CGPoint)theCenterPoint atIndex:(NSUInteger)theIndex {
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(theCenterPoint.x - 1.5 - [self MAXLineChartLeftMarginWidth: theChartView], theCenterPoint.y - 10, [self MAXLineChartLeftMarginWidth: theChartView] + [self MAXLineChartLeftBorderWidthForChart: theChartView],  20)];
    
    UIView *dotView = [[UIView alloc] initWithFrame: CGRectMake(CGRectGetWidth(containerView.frame) - 10, CGRectGetHeight(containerView.frame) / 2.0 - 0.5, 10, 1)];
    dotView.backgroundColor = [UIColor flatBlackColor];
    [containerView addSubview: dotView];
    
    
    UILabel * indexValueLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(containerView.frame) - (CGRectGetWidth(containerView.frame) - CGRectGetMinX(dotView.frame)), CGRectGetHeight(containerView.frame))];
    indexValueLabel.textAlignment = NSTextAlignmentCenter;
    indexValueLabel.textColor = [UIColor flatBlackColor];
    indexValueLabel.font = [UIFont helveticaNeueBoldWithSize: 12.0];
    indexValueLabel.text = [NSString stringWithFormat:@"%.0f", [self MAXLineChart: theChartView yValueForLeftBorderDecorationViewAtIndex: theIndex]];
    indexValueLabel.adjustsFontSizeToFitWidth = YES;
    indexValueLabel.minimumScaleFactor = 0.7;
    [containerView addSubview: indexValueLabel];
    
    return containerView;
}

#pragma mark - Right Border Decoration Views

-(NSUInteger)MAXLineChartNumberOfDecorationViewsForLowerBorder:(MAXLineChartView *)theLineChart {
    
    return 5;
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView xValueForLowerBorderDecorationViewAtIndex:(NSUInteger)theIndex {
    
    double highestXValue = [self MAXHighestXValueForLineChart: theChartView];
    
    return theIndex * highestXValue / ([self MAXLineChartNumberOfDecorationViewsForLowerBorder: theChartView] - 1);
}

-(UIView *)MAXLineChart:(MAXLineChartView *)theChartView lowerBorderDecorationViewAxisCenterPoint:(CGPoint)theCenterPoint atIndex:(NSUInteger)theIndex {
    
    UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake(theCenterPoint.x - 20, theCenterPoint.y - 1.5, 40, [self MAXLineChartLowerMarginHeight: theChartView] + [self MAXLineChartLowerBorderHeightForChart: theChartView])];
    
    
    UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(containerView.frame) / 2.0 - 0.5, 0, 1, 10)];
    dotView.backgroundColor = [UIColor flatBlackColor];
    [containerView addSubview: dotView];
    
    UILabel *indexValueLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(dotView.frame), CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame) - CGRectGetMaxY(dotView.frame))];
    indexValueLabel.textAlignment = NSTextAlignmentCenter;
    indexValueLabel.textColor = [UIColor flatBlackColor];
    indexValueLabel.font = [UIFont helveticaNeueBoldWithSize: 12.0];
    indexValueLabel.text = [NSString stringWithFormat:@"%.0f", [self MAXLineChart: theChartView xValueForLowerBorderDecorationViewAtIndex:theIndex] ];
    indexValueLabel.adjustsFontSizeToFitWidth = YES;
    indexValueLabel.minimumScaleFactor = 0.7;
    [containerView addSubview: indexValueLabel];
    
    return containerView;
}

#pragma mark - Decoration views for lines

-(NSUInteger)MAXLineChart:(MAXLineChartView *)theChartView numDecorationViewsForLine:(NSUInteger)theLine {
    
    return [_viewModel numReinforcersForLineAtIndex: theLine];
}

-(UIView *)MAXLineChart:(MAXLineChartView *)theChartView decorationViewForLine:(NSUInteger)theLine atIndex:(NSUInteger)theIndex decorationViewPosition:(CGPoint)theDecorationViewPosition {
    
    UIView *comparisonView = [[UIView alloc] initWithFrame: CGRectMake( theDecorationViewPosition.x -1.5 - [self MAXLineChartLeftBorderWidthForChart: _bigLineChart], theDecorationViewPosition.y - 10, [self MAXLineChartLeftBorderWidthForChart: _bigLineChart] + [self MAXLineChartLeftBorderWidthForChart: _bigLineChart], 20)];
    
    comparisonView.backgroundColor = [UIColor blueColor];
    
    return comparisonView;
    
}

#pragma mark - Margins

-(CGFloat)MAXLineChartLeftMarginWidth:(MAXLineChartView *)theLineChart {
    
    return 50.0;
}

-(CGFloat)MAXLineChartRightMarginWidth:(MAXLineChartView *)theLineChart {
    
    return 20.0;
}

-(CGFloat)MAXLineChartUpperMarginHeight:(MAXLineChartView *)theLineChart {
    
    return 20.0;
}

-(CGFloat)MAXLineChartLowerMarginHeight:(MAXLineChartView *)theLineChart {
    
    return 40.0;
}

#pragma mark - Line Chart Delegate & Data Source

-(NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
    return [_viewModel numLines];
}

-(NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    return [_viewModel numValuesForLineAtIndex:lineIndex];
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    return [_viewModel valueForLineAtIndex:lineIndex withHorizontalIndex:horizontalIndex];
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex {
    return 2.0;
}

-(UIColor*)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    return [_viewModel colorForLineAtIndex:lineIndex];
}



#pragma mark - Block view Delegate & Datasource

-(void)blocksView:(MAXBlockView *)theBlockView block:(UIView *)theBlock forRow:(NSUInteger)theRow forCol:(NSUInteger)theCol {
    [self labelTitleForColView:theBlock withString:[_viewModel titleForRow:theRow col:theCol]];
    [self labelForColView:theBlock withString:[_viewModel dataTitleForRow:theRow col:theCol]];
}

-(NSInteger)numRowsInBlockView:(MAXBlockView *)theBlockView {
    return 7;
}

-(NSInteger)numColumnsInBlockView:(MAXBlockView *)theBlockView inRow:(NSUInteger)theRow {
    
    
    return 2;
}

-(CGFloat)heightForRow:(NSUInteger)theRow {
    return 80;
}

-(UIColor*)colorForBlockInRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn {
    return [UIColor flatTealColor];
}

-(CGFloat)heightForHorizontalSepratorForRow:(NSUInteger)theRow {
    return 2.0;
}

-(CGFloat)widthForVerticalSeparatorForRow:(NSUInteger)theRow {
    return 2.0;
}

-(UIColor*)colorForHorizontalSepratorForRow:(NSUInteger)theRow {
    return [UIColor flatTealColorDark];
}

-(UIColor*)colorForVerticalSeparatorForRow:(NSUInteger)theRow forColumn:(NSUInteger)theColumn {
    return [UIColor flatTealColorDark];
}

#pragma mark - Helpers For Block View

-(void)labelTitleForColView:(UIView*)theView withString:(NSString*)theString {
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(theView.frame), CGRectGetHeight(theView.frame) * 0.2)];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor flatWhiteColorDark];
    labelTitle.text = theString;
    labelTitle.font = [UIFont openSansWithSize:CGRectGetHeight(labelTitle.frame) * 0.8];
    labelTitle.adjustsFontSizeToFitWidth = YES;
    [theView addSubview:labelTitle];
}

-(void)labelForColView:(UIView*)theView withString:(NSString*)theString {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(theView.frame) * 0.2, CGRectGetWidth(theView.frame), CGRectGetHeight(theView.frame) * 0.8)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor flatWhiteColor];
    label.text = theString;
    label.font = [UIFont openSansBoldWithSize:CGRectGetHeight(label.frame) * 0.6];
    label.adjustsFontSizeToFitWidth = YES;
    [theView addSubview:label];
}


#pragma mark - Navigation

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
