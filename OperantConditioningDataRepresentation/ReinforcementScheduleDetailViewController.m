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


@interface ReinforcementScheduleDetailViewController () <MAXBlockViewDelegate, MAXBlockViewDatasource, JBLineChartViewDataSource, JBLineChartViewDelegate> {
    ReinforcementScheduleDetailViewModel *_viewModel;
    JBLineChartView *_lineChart;
    UIScrollView *_scrollView;
}

@end

@implementation ReinforcementScheduleDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _viewModel = [[ReinforcementScheduleDetailViewModel alloc] initWithRandomUser:_randomUsers withReinforcementSchedule:_reinforcementSchedule];
    
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
    
    // containing scroll view
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(navBar.frame))];
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
    
    
    UILabel *maxYValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_lineChart.frame) - 25, 40, 50, CGRectGetMinY(_lineChart.frame) - CGRectGetHeight(navBar.frame))];
    maxYValueLabel.textAlignment = NSTextAlignmentCenter;
    maxYValueLabel.textColor = [UIColor flatSkyBlueColor];
    maxYValueLabel.text = [_viewModel maxYValueString];
    maxYValueLabel.font = [UIFont openSansBoldWithSize:18.0];
    [_scrollView addSubview:maxYValueLabel];
    
    
    MAXBlockView *blockView = [[MAXBlockView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lineChart.frame) + 40, CGRectGetWidth(self.view.frame), 400)];
    blockView.delegate = self;
    blockView.datasource = self;
    [blockView reloadData];
    [_scrollView addSubview:blockView];
    
    
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:_lineChart animated:YES];
    progressHud.mode = MBProgressHUDModeIndeterminate;
    
    [_viewModel downloadBehaviorWithLastObjectId:nil WithCompletion:^(BOOL succeeded) {
        
        [progressHud hide:YES];
        
        if (succeeded == YES) {
            [_lineChart reloadData];
            [blockView reloadData];
        }
        
    }];
    
    [_viewModel downloadReinforcersSkipping:0 withCompletion:^(NSError *theError) {
        
        if (theError == nil) {
            [blockView reloadData];
        }
        
    }];
    
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
    return 2;
}

-(NSInteger)numColumnsInBlockView:(MAXBlockView *)theBlockView inRow:(NSUInteger)theRow {
    
    if (theRow == 1) {
        return 2;
    }
    
    return 1;
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
