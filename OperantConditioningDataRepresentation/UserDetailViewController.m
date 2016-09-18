//
//  UserDetailViewController.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 07/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UserDetailViewController.h"
#import "UserDetailViewModel.h"
#import "JBLineChartView.h"
#import "UIColor+Chameleon.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "MBProgressHUD.h"

#import "MAXPagingScrollView.h"
#import "MAXLineChartView.h"
#import "MAXBlockView.h"


@interface UserDetailViewController () <JBLineChartViewDataSource, JBLineChartViewDelegate, MAXLineChartDelegate, MAXLineChartDataSource, MAXBlockViewDatasource, MAXBlockViewDelegate> {
    
    JBLineChartView *lineChart;
    MAXLineChartView *_cumulativeLineChart;
    UserDetailViewModel *_viewModel;
    UILabel *avgTime, *avgReinforcerTime;
    UILabel *stdTime, *stdReinforcerTime;
    UILabel *maxYValueLabel;
    UILabel *userGenderLabel, *userPlayFreq, *userPlayAmount;
    UIView *includeOrExcludeView;
    
    UIScrollView *_scrollView;
    
}

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewModel = [[UserDetailViewModel alloc] initWithUser:_randomUser];
    
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
    title.text = [_viewModel userId];
    title.font = [UIFont maxwellBoldWithSize:19.0];
    [navBar addSubview:title];
    
    CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    CGFloat screenHeight = CGRectGetHeight(self.view.frame) - 64;
    
    _cumulativeLineChart = [[MAXLineChartView alloc] initWithFrame:CGRectMake(30, 0, screenHeight, screenWidth)];
    _cumulativeLineChart.datasource = self;
    _cumulativeLineChart.delegate = self;
    
    MAXPagingScrollView *pageView = [[MAXPagingScrollView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
    
    [pageView MAXScrollViewNumPagesWithBlock:^ NSInteger {
        
        return 2;
    }];
    
    [pageView MAXScrollViewWithViewAtPageBlock:^(UIView *theView, NSInteger page) {
       
        if (page == 0) {
            [theView addSubview: [self p_createSollViewOne]];
        }
        else {
            [theView addSubview: _cumulativeLineChart];
        }
        
    }];
    
    [self.view addSubview: pageView];
    
    
    [lineChart reloadData];
    [_cumulativeLineChart reloadData];
    
    _cumulativeLineChart.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
    _cumulativeLineChart.frame = CGRectMake(0, 0, CGRectGetWidth(_cumulativeLineChart.frame), CGRectGetHeight(_cumulativeLineChart.frame));
    [pageView reloadDataBlocks];
    
    [self updateData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateData {
    avgTime.text = [_viewModel avgBehavior];
    stdTime.text = [_viewModel stdDevBehavior];
    avgReinforcerTime.text = [_viewModel avgReinforcer];
    stdReinforcerTime.text = [_viewModel stdDevReinforcer];
    userGenderLabel.text = [_viewModel userGender];
    userPlayFreq.text = [_viewModel userPlayFreq];
    maxYValueLabel.text = [_viewModel maxYValue];
}

-(void)includeOrExcludeData:(UIButton*)sender {
    [_viewModel includeOrExcludeData];
    sender.selected = !sender.selected;
    
    if ([_viewModel isExcluded]) {
        includeOrExcludeView.backgroundColor = [UIColor flatGreenColor];
    }
    else {
        includeOrExcludeView.backgroundColor = [UIColor flatRedColor];
    }
    
}

-(UIScrollView *)p_createSollViewOne {
    
    // containing scroll view
    if (_scrollView == nil) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
        [self.view addSubview:_scrollView];
        
        // chart
        lineChart = [[JBLineChartView alloc] initWithFrame:CGRectMake(30, 40, CGRectGetWidth(self.view.frame) - 60, 240)];
        lineChart.delegate = self;
        lineChart.dataSource = self;
        [lineChart setMinimumValue:0];
        [lineChart setMaximumValue:1100];
        [_scrollView addSubview:lineChart];
        
        UIView *yAxis = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(lineChart.frame) - 2, CGRectGetMinY(lineChart.frame), 2, CGRectGetHeight(lineChart.frame))];
        yAxis.backgroundColor = [UIColor flatSkyBlueColor];
        [_scrollView addSubview:yAxis];
        
        UIView *xAxis = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(lineChart.frame) - 2, CGRectGetMaxY(lineChart.frame), CGRectGetWidth(lineChart.frame) + 2, 2)];
        xAxis.backgroundColor = [UIColor flatSkyBlueColor];
        [_scrollView addSubview:xAxis];
        
        UILabel *chartXAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMaxY(lineChart.frame), 180, 40)];
        chartXAxisLabel.textAlignment = NSTextAlignmentCenter;
        chartXAxisLabel.textColor = [UIColor flatSkyBlueColor];
        chartXAxisLabel.text = @"Time (s)";
        chartXAxisLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:chartXAxisLabel];
        
        UILabel *originLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(lineChart.frame) - 10, CGRectGetMaxY(lineChart.frame), 20, 40)];
        originLabel.textAlignment = NSTextAlignmentCenter;
        originLabel.textColor = [UIColor flatSkyBlueColor];
        originLabel.text = @"0";
        originLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:originLabel];
        
        UILabel *maxValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineChart.frame) - 20, CGRectGetMaxY(lineChart.frame), 40, 40)];
        maxValueLabel.textAlignment = NSTextAlignmentCenter;
        maxValueLabel.textColor = [UIColor flatSkyBlueColor];
        maxValueLabel.text = [_viewModel maxXValue];
        maxValueLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:maxValueLabel];
        
        maxYValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(lineChart.frame) - 25, 40, 50, CGRectGetMinY(lineChart.frame) - 64)];
        maxYValueLabel.textAlignment = NSTextAlignmentCenter;
        maxYValueLabel.textColor = [UIColor flatSkyBlueColor];
        maxYValueLabel.text = [_viewModel maxYValue];
        maxYValueLabel.font = [UIFont openSansBoldWithSize:18.0];
        [_scrollView addSubview:maxYValueLabel];
        
        // MAXBlock View
        
        MAXBlockView *blockView = [[MAXBlockView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineChart.frame) + 50, CGRectGetWidth(self.view.frame), 7 * 80)];
        blockView.datasource = self;
        blockView.delegate = self;
        [blockView reloadData];
        [_scrollView addSubview: blockView];
        
        // Include or exclude button at the bottom
        includeOrExcludeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(blockView.frame), CGRectGetWidth(self.view.frame), 60)];
        
        if ([_viewModel isExcluded]) {
            includeOrExcludeView.backgroundColor = [UIColor flatGreenColor];
        }
        else {
            includeOrExcludeView.backgroundColor = [UIColor flatRedColor];
        }
        
        [_scrollView addSubview:includeOrExcludeView];
        
        UIButton *includeOrExcludeLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        includeOrExcludeLabel.frame = CGRectMake(0, 0, CGRectGetWidth(includeOrExcludeView.frame), CGRectGetHeight(includeOrExcludeView.frame));
        [includeOrExcludeLabel setTitle:@"Exclude" forState:UIControlStateNormal];
        [includeOrExcludeLabel setTitle:@"Include" forState:UIControlStateSelected];
        [includeOrExcludeLabel setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateNormal];
        [includeOrExcludeLabel setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateSelected];
        [includeOrExcludeLabel setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [includeOrExcludeLabel setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        [includeOrExcludeLabel addTarget:self action:@selector(includeOrExcludeData:) forControlEvents:UIControlEventTouchUpInside];
        includeOrExcludeLabel.titleLabel.font = [UIFont openSansBoldWithSize:17.0];
        
        if ([_viewModel isExcluded]) {
            includeOrExcludeLabel.selected = YES;
        }
        else {
            includeOrExcludeLabel.selected = NO;
        }
        
        [includeOrExcludeView addSubview:includeOrExcludeLabel];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(includeOrExcludeView.frame));
        
        
    }
    
    
    return _scrollView;
    
}


#pragma mark - Line Chart Delegate & Data source

-(NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
    return [_viewModel numberOfLines];
}

-(NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    return [_viewModel numberOfVerticalValuesAtIndes:lineIndex];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    return [_viewModel verticalValueForHorizontalIndex:horizontalIndex];
}

-(UIColor*)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    return [UIColor flatSkyBlueColor];
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex {
    return 2.0;
}

#pragma mark - line chart delegate

-(NSUInteger)MAXNumberOfLinesForChart:(MAXLineChartView *)theChartView {
    
    return [_viewModel numberOfLines];
}

-(NSUInteger)MAXLineChart:(MAXLineChartView *)theChartView numberOfXValuesForLine:(NSUInteger)theLine {
    
    return [_viewModel numberOfVerticalValuesAtIndes: theLine];
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView YValueAtX:(NSUInteger)theX line:(NSUInteger)theLine {
    
    CGFloat verticalValue = [_viewModel verticalValueForHorizontalIndex: theX];
    return verticalValue;
}

-(UIColor *)MAXLineChart:(MAXLineChartView *)theLineChart strokeColorForLine:(NSUInteger)theLine {
    
    return [UIColor flatBlackColor];
}

-(CGFloat)MAXLineChart:(MAXLineChartView *)TheLineChart widthForLine:(NSUInteger)theLine {
    
    return 2.0;
}

-(double)MAXhighestYValueForLineChart:(MAXLineChartView *)theLineChart {
    
    return [_viewModel highestYValue];
}

-(double)MAXHighestXValueForLineChart:(MAXLineChartView *)theLineChart {
    
    return [_viewModel numberOfVerticalValuesAtIndes: 0];
}

-(CGFloat)MAXLineChartLeftBorderWidthForChart:(MAXLineChartView *)theLineChart {
    
    return 3;
}

-(CGFloat)MAXLineChartLowerBorderHeightForChart:(MAXLineChartView *)theLineChart {
    
    return 3;
}

-(UIColor *)MAXLineChartColorsForBordersForChart:(MAXLineChartView *)theLineChart {
    
    return [UIColor flatBlackColor];
}


#pragma mark - Line Decoration Views

-(NSUInteger)MAXLineChart:(MAXLineChartView *)theChartView numDecorationViewsForLine:(NSUInteger)theLine {
    
    return [_viewModel numberOfReinforcers];
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView xValueForDecorationViewForLine:(NSUInteger)theLine atIndex:(NSUInteger)theIndex {
    
    
    return [_viewModel horizontalValueForReinforcerAtIndex: theIndex];
}

-(UIView *)MAXLineChart:(MAXLineChartView *)theChartView decorationViewForLine:(NSUInteger)theLine atIndex:(NSUInteger)theIndex decorationViewPosition:(CGPoint)theDecorationViewPosition {
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake( theDecorationViewPosition.x - 0.5, theDecorationViewPosition.y - 1, 1, 10)];
    view.backgroundColor = [UIColor flatBlackColor];
    
    return view;
}


#pragma mark - Left decoration views

-(NSUInteger)MAXLineChartNumberOfDecorationViewsForLeftBorder:(MAXLineChartView *)theLineChart {
    
    return 5;
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView yValueForLeftBorderDecorationViewAtIndex:(NSUInteger)theIndex {
    
    return theIndex * [self MAXhighestYValueForLineChart: _cumulativeLineChart] / ([self MAXLineChartNumberOfDecorationViewsForLeftBorder:  _cumulativeLineChart] -1);
}

-(UIView *)MAXLineChart:(MAXLineChartView *)theChartView leftBorderDecorationViewAxisCenterPoint:(CGPoint)theCenterPoint atIndex:(NSUInteger)theIndex {
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(theCenterPoint.x - 1.5 - [self MAXLineChartLeftMarginWidth: _cumulativeLineChart], theCenterPoint.y - 10, [self MAXLineChartLeftMarginWidth: _cumulativeLineChart] + [self MAXLineChartLeftBorderWidthForChart: _cumulativeLineChart], 20)];
    
    
    UIView *dotView = [[UIView alloc] initWithFrame: CGRectMake(CGRectGetWidth(container.frame) - 10, CGRectGetHeight(container.frame) / 2.0 - 0.5, 10, 1)];
    dotView.backgroundColor = [UIColor blackColor];
    [container addSubview: dotView];
    
    
    UILabel *indexValueLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(container.frame) - (CGRectGetWidth(container.frame) - CGRectGetMinX(dotView.frame)), CGRectGetHeight(container.frame))];
    indexValueLabel.textAlignment = NSTextAlignmentCenter;
    indexValueLabel.textColor = [UIColor flatBlackColor];
    indexValueLabel.font = [UIFont helveticaNeueBoldWithSize: 12.0];
    indexValueLabel.text = [NSString stringWithFormat:@"%.0f", [self MAXLineChart: _cumulativeLineChart yValueForLeftBorderDecorationViewAtIndex: theIndex]];
    indexValueLabel.adjustsFontSizeToFitWidth = YES;
    indexValueLabel.minimumScaleFactor = 0.7;
    [container addSubview: indexValueLabel];
    
    return container;
    
}

#pragma mark - Bottom Decoration Views

-(NSUInteger)MAXLineChartNumberOfDecorationViewsForLowerBorder:(MAXLineChartView *)theLineChart {
    
    return 5;
}

-(double)MAXLineChart:(MAXLineChartView *)theChartView xValueForLowerBorderDecorationViewAtIndex:(NSUInteger)theIndex {
    
    return theIndex * [self MAXHighestXValueForLineChart: _cumulativeLineChart] / ([self MAXLineChartNumberOfDecorationViewsForLowerBorder: _cumulativeLineChart] - 1);
}

-(UIView *)MAXLineChart:(MAXLineChartView *)theChartView lowerBorderDecorationViewAxisCenterPoint:(CGPoint)theCenterPoint atIndex:(NSUInteger)theIndex {
    
    UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake(theCenterPoint.x - 20, theCenterPoint.y - 1.5, 40, [self MAXLineChartLowerMarginHeight: _cumulativeLineChart] + [self MAXLineChartLowerBorderHeightForChart: _cumulativeLineChart])];
    
    UIView *dotView = [[UIView alloc] initWithFrame: CGRectMake(CGRectGetWidth(containerView.frame) / 2.0 - 0.5, 0, 1, 10)];
    dotView.backgroundColor = [UIColor flatBlackColor];
    [containerView addSubview: dotView];
    
    UILabel *indexValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dotView.frame), CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame) - CGRectGetMaxY(dotView.frame))];
    indexValueLabel.textAlignment = NSTextAlignmentCenter;
    indexValueLabel.textColor = [UIColor flatBlackColor];
    indexValueLabel.font = [UIFont helveticaNeueBoldWithSize: 12.0];
    indexValueLabel.text = [NSString stringWithFormat:@"%.0f", [self MAXLineChart: _cumulativeLineChart xValueForLowerBorderDecorationViewAtIndex: theIndex]];
    indexValueLabel.adjustsFontSizeToFitWidth = YES;
    indexValueLabel.minimumScaleFactor = 0.7;
    [containerView addSubview: indexValueLabel];
    
    return containerView;
}

#pragma mark - Marings

-(CGFloat)MAXLineChartLeftMarginWidth:(MAXLineChartView *)theLineChart {
    
    return 50;
}

-(CGFloat)MAXLineChartRightMarginWidth:(MAXLineChartView *)theLineChart {
    
    return 20;
}

-(CGFloat)MAXLineChartUpperMarginHeight:(MAXLineChartView *)theLineChart {
    
    return  20;
}

-(CGFloat)MAXLineChartLowerMarginHeight:(MAXLineChartView *)theLineChart {
    
    return 30;
}


#pragma mark - Block view delegate

-(void)blocksView:(MAXBlockView *)theBlockView block:(UIView *)theBlock forRow:(NSUInteger)theRow forCol:(NSUInteger)theCol {
    
    [self labelTitleForColView: theBlock withString: [_viewModel titleForRow: theRow col: theCol]];
    [self labelForColView: theBlock withString: [_viewModel dataStringForRow: theRow col: theCol]];
    
}

-(NSInteger)numRowsInBlockView:(MAXBlockView *)theBlockView {
    
    return 9;
}

-(NSInteger)numColumnsInBlockView:(MAXBlockView *)theBlockView inRow:(NSUInteger)theRow {
    
    if (theRow == 0 || theRow == 1 || theRow == 7) {
        return 1;
    }
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
