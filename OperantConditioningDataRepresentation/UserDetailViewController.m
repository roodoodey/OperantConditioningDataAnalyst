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


@interface UserDetailViewController () <JBLineChartViewDataSource, JBLineChartViewDelegate> {
    JBLineChartView *lineChart;
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
    
    
    // containing scroll view
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(navBar.frame))];
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
    
    maxYValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(lineChart.frame) - 25, 40, 50, CGRectGetMinY(lineChart.frame) - CGRectGetHeight(navBar.frame))];
    maxYValueLabel.textAlignment = NSTextAlignmentCenter;
    maxYValueLabel.textColor = [UIColor flatSkyBlueColor];
    maxYValueLabel.text = [_viewModel maxYValue];
    maxYValueLabel.font = [UIFont openSansBoldWithSize:18.0];
    [_scrollView addSubview:maxYValueLabel];
    
    // bottom view
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineChart.frame) + 40, CGRectGetWidth(self.view.frame), 2)];
    topSeparator.backgroundColor = [UIColor flatTealColorDark];
    [_scrollView addSubview:topSeparator];
    
    UIView *elapsedTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topSeparator.frame), CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 0.2)];
    elapsedTimeView.backgroundColor = [UIColor flatTealColor];
    [_scrollView addSubview:elapsedTimeView];
    
    UILabel *elapsedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(elapsedTimeView.frame) * 0.2)];
    elapsedTimeLabel.textAlignment = NSTextAlignmentCenter;
    elapsedTimeLabel.textColor = [UIColor flatWhiteColorDark];
    elapsedTimeLabel.text = @"Elapsed Time";
    elapsedTimeLabel.font = [UIFont openSansWithSize:CGRectGetHeight(elapsedTimeLabel.frame) * 0.68];
    [elapsedTimeView addSubview:elapsedTimeLabel];
    
    UILabel *elapsedTime = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(elapsedTimeLabel.frame), CGRectGetWidth(elapsedTimeView.frame), CGRectGetHeight(elapsedTimeView.frame) - CGRectGetMaxY(elapsedTimeLabel.frame))];
    elapsedTime.textAlignment = NSTextAlignmentCenter;
    
    if ([_viewModel sessionLengthIncorrect]) {
        elapsedTime.textColor = [UIColor flatYellowColor];
    }
    else {
        elapsedTime.textColor = [UIColor flatWhiteColor];
    }
    
    elapsedTime.text = [_viewModel sessionLength];
    elapsedTime.font = [UIFont openSansBoldWithSize:CGRectGetHeight(elapsedTime.frame) * 0.7];
    [elapsedTimeView addSubview:elapsedTime];
    
    UIView *horizontalSeparatorOne = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(elapsedTimeView.frame), CGRectGetWidth(self.view.frame), 2)];
    horizontalSeparatorOne.backgroundColor = [UIColor flatTealColorDark];
    [_scrollView addSubview:horizontalSeparatorOne];
    
    
    ////////////////////////////////////////////////
    // Behavior data
    
    UIView *behaviorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(horizontalSeparatorOne.frame), CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 0.2)];
    behaviorView.backgroundColor = [UIColor flatTealColor];
    
    UIView *middleSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(behaviorView.frame) - 1, 0, 2, CGRectGetHeight(behaviorView.frame))];
    middleSeparator.backgroundColor = [UIColor flatTealColorDark];
    [behaviorView addSubview:middleSeparator];
    
    [_scrollView addSubview:behaviorView];
    
    UILabel *avgTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(behaviorView.frame) / 2.0 - 1, CGRectGetHeight(behaviorView.frame) * 0.2)];
    avgTimeLabel.textAlignment = NSTextAlignmentCenter;
    avgTimeLabel.textColor = [UIColor flatWhiteColorDark];
    avgTimeLabel.text = @"Avg. Behavior (30 sec)";
    avgTimeLabel.font = [UIFont openSansWithSize:CGRectGetHeight(avgTimeLabel.frame) * 0.7];
    [behaviorView addSubview:avgTimeLabel];
    
    avgTime = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(avgTimeLabel.frame), CGRectGetWidth(avgTimeLabel.frame), CGRectGetHeight(behaviorView.frame) - CGRectGetHeight(avgTimeLabel.frame))];
    avgTime.textAlignment = NSTextAlignmentCenter;
    avgTime.textColor = [UIColor flatWhiteColor];
    avgTime.text = [_viewModel avgBehavior];
    avgTime.font = [UIFont openSansBoldWithSize:CGRectGetHeight(avgTime.frame) * 0.7];
    [behaviorView addSubview:avgTime];
    
    UILabel *stdTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(behaviorView.frame)/2.0 + 1, 0, CGRectGetWidth(behaviorView.frame)/2.0 - 1, CGRectGetHeight(behaviorView.frame) * 0.2)];
    stdTimeLabel.textAlignment = NSTextAlignmentCenter;
    stdTimeLabel.textColor = [UIColor flatWhiteColorDark];
    stdTimeLabel.text = @"Std. Behavior (30 sec)";
    stdTimeLabel.font = [UIFont openSansWithSize:CGRectGetHeight(stdTimeLabel.frame) * 0.7];
    [behaviorView addSubview:stdTimeLabel];
    
    stdTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(stdTimeLabel.frame), CGRectGetHeight(stdTimeLabel.frame), CGRectGetWidth(stdTimeLabel.frame), CGRectGetHeight(behaviorView.frame) - CGRectGetHeight(stdTimeLabel.frame))];
    stdTime.textAlignment = NSTextAlignmentCenter;
    stdTime.textColor = [UIColor flatWhiteColor];
    stdTime.text = [_viewModel stdDevBehavior];
    stdTime.font = [UIFont openSansBoldWithSize:CGRectGetHeight(stdTime.frame) * 0.7];
    [behaviorView addSubview:stdTime];
    
    UIView *horizontalSeparatorTwo = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(behaviorView.frame), CGRectGetWidth(self.view.frame), 2)];
    horizontalSeparatorTwo.backgroundColor = [UIColor flatTealColorDark];
    [_scrollView addSubview:horizontalSeparatorTwo];
    
    /////////////////////////////////////////////////////
    // Reinforcer data
    
    UIView *reinforcerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(horizontalSeparatorTwo.frame), CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 0.2)];
    reinforcerView.backgroundColor = [UIColor flatTealColor];
    
    UIView *middleSeparatorTwo = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(reinforcerView.frame) - 1, 0, 2, CGRectGetHeight(reinforcerView.frame))];
    middleSeparatorTwo.backgroundColor = [UIColor flatTealColorDark];
    [reinforcerView addSubview:middleSeparatorTwo];
    
    [_scrollView addSubview:reinforcerView];
    
    UILabel *avgReinforcerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(reinforcerView.frame) / 2.0 - 1, CGRectGetHeight(reinforcerView.frame) * 0.2)];
    avgReinforcerLabel.textAlignment = NSTextAlignmentCenter;
    avgReinforcerLabel.textColor = [UIColor flatWhiteColorDark];
    avgReinforcerLabel.text = @"Avg. Reinforcer (30 sec)";
    avgReinforcerLabel.font = [UIFont openSansWithSize:CGRectGetHeight(avgReinforcerLabel.frame) * 0.7];
    [reinforcerView addSubview:avgReinforcerLabel];
    
    avgReinforcerTime = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(avgReinforcerLabel.frame), CGRectGetWidth(avgReinforcerLabel.frame), CGRectGetHeight(behaviorView.frame) - CGRectGetHeight(avgReinforcerLabel.frame))];
    avgReinforcerTime.textAlignment = NSTextAlignmentCenter;
    avgReinforcerTime.textColor = [UIColor flatWhiteColor];
    avgReinforcerTime.text = [_viewModel avgReinforcer];
    avgReinforcerTime.font = [UIFont openSansBoldWithSize:CGRectGetHeight(avgReinforcerTime.frame) * 0.7];
    [reinforcerView addSubview:avgReinforcerTime];
    
    UILabel *stdReinforcerTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(reinforcerView.frame) / 2.0 + 1, 0, CGRectGetWidth(reinforcerView.frame) / 2 - 1, CGRectGetHeight(reinforcerView.frame) * 0.2)];
    stdReinforcerTitle.textAlignment = NSTextAlignmentCenter;
    stdReinforcerTitle.textColor = [UIColor flatWhiteColorDark];
    stdReinforcerTitle.text = @"Std. Reinforcer (30 sec)";
    stdReinforcerTitle.font = [UIFont openSansWithSize:CGRectGetHeight(stdReinforcerTitle.frame) * 0.7];
    [reinforcerView addSubview:stdReinforcerTitle];
    
    stdReinforcerTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(stdReinforcerTitle.frame), CGRectGetMaxY(stdReinforcerTitle.frame), CGRectGetWidth(stdReinforcerTitle.frame), CGRectGetHeight(reinforcerView.frame) - CGRectGetHeight(stdReinforcerTitle.frame))];
    stdReinforcerTime.textAlignment = NSTextAlignmentCenter;
    stdReinforcerTime.textColor = [UIColor flatWhiteColor];
    stdReinforcerTime.text = [_viewModel stdDevReinforcer];
    stdReinforcerTime.font = [UIFont openSansBoldWithSize:CGRectGetHeight(stdReinforcerTime.frame) * 0.7];
    [reinforcerView addSubview:stdReinforcerTime];
    
    
    ////////////////////////////////////////
    // gender and questionnaire information
    
    UIView *separatorThree = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(reinforcerView.frame), CGRectGetWidth(self.view.frame), 2)];
    separatorThree.backgroundColor = [UIColor flatTealColorDark];
    [_scrollView addSubview:separatorThree];
    
    UIView *genderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(separatorThree.frame), CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 0.2)];
    genderView.backgroundColor = [UIColor flatTealColor];
    [_scrollView addSubview:genderView];
    
    
    UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(genderView.frame), CGRectGetHeight(genderView.frame) * 0.2)];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.textColor = [UIColor flatWhiteColorDark];
    genderLabel.text = @"Gender";
    genderLabel.font = [UIFont openSansWithSize:CGRectGetHeight(genderLabel.frame) * 0.7];
    [genderView addSubview:genderLabel];
    
    
    userGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(genderLabel.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(genderView.frame) - CGRectGetHeight(genderLabel.frame))];
    userGenderLabel.textAlignment = NSTextAlignmentCenter;
    userGenderLabel.textColor = [UIColor flatWhiteColor];
    userGenderLabel.text = [_viewModel userGender];
    userGenderLabel.font = [UIFont openSansBoldWithSize:CGRectGetHeight(userGenderLabel.frame) * 0.7];
    [genderView addSubview:userGenderLabel];
    
    UIView *separatorFour = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(genderView.frame), CGRectGetWidth(genderView.frame), 2)];
    separatorFour.backgroundColor = [UIColor flatTealColorDark];
    [_scrollView addSubview:separatorFour];
    
    UIView *questionsViews = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(separatorFour.frame), CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 0.2)];
    questionsViews.backgroundColor = [UIColor flatTealColor];
    [_scrollView addSubview:questionsViews];
    
    UILabel *playFreqLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(questionsViews.frame) / 2.0 - 1, CGRectGetHeight(questionsViews.frame) * 0.2)];
    playFreqLabel.textAlignment = NSTextAlignmentCenter;
    playFreqLabel.textColor = [UIColor flatWhiteColorDark];
    playFreqLabel.text = @"Play Frequency a week";
    playFreqLabel.font = [UIFont openSansWithSize:CGRectGetHeight(playFreqLabel.frame) * 0.7];
    [questionsViews addSubview:playFreqLabel];
    
    userPlayFreq = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(playFreqLabel.frame), CGRectGetWidth(playFreqLabel.frame), CGRectGetHeight(questionsViews.frame) - CGRectGetHeight(playFreqLabel.frame))];
    userPlayFreq.textAlignment = NSTextAlignmentCenter;
    userPlayFreq.textColor = [UIColor flatWhiteColor];
    userPlayFreq.text = [_viewModel userPlayFreq];
    userPlayFreq.font = [UIFont openSansBoldWithSize:CGRectGetHeight(userPlayFreq.frame) * 0.7];
    [questionsViews addSubview:userPlayFreq];
    
    UIView *verticalSeparatorLast = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(questionsViews.frame) - 1, 0, 2, CGRectGetHeight(questionsViews.frame))];
    verticalSeparatorLast.backgroundColor = [UIColor flatTealColorDark];
    [questionsViews addSubview:verticalSeparatorLast];
    
    UILabel *playAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(questionsViews.frame) / 2.0 + 1, 0, CGRectGetWidth(questionsViews.frame) / 2.0 - 1, CGRectGetHeight(questionsViews.frame) * 0.2)];
    playAmountLabel.textAlignment = NSTextAlignmentCenter;
    playAmountLabel.textColor = [UIColor flatWhiteColorDark];
    playAmountLabel.text = @"Play Amount (hours / week)";
    playAmountLabel.font = [UIFont openSansWithSize:CGRectGetHeight(playAmountLabel.frame) * 0.7];
    [questionsViews addSubview:playAmountLabel];
    
    userPlayAmount = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(questionsViews.frame) / 2.0 + 1, CGRectGetMaxY(playAmountLabel.frame), CGRectGetWidth(questionsViews.frame) / 2.0 - 1, CGRectGetHeight(questionsViews.frame) - CGRectGetHeight(playAmountLabel.frame))];
    userPlayAmount.textAlignment = NSTextAlignmentCenter;
    userPlayAmount.textColor = [UIColor flatWhiteColor];
    userPlayAmount.text = [_viewModel userPlayAmount];
    userPlayAmount.font = [UIFont openSansBoldWithSize:CGRectGetHeight(userPlayAmount.frame) * 0.7];
    [questionsViews addSubview:userPlayAmount];
    
    UIView *separatorFive = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(questionsViews.frame), CGRectGetWidth(self.view.frame), 2)];
    separatorFive.backgroundColor = [UIColor flatTealColorDark];
    [_scrollView addSubview:separatorFive];
    
    // Include or exclude button at the bottom
    includeOrExcludeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(separatorFive.frame), CGRectGetWidth(self.view.frame), 60)];
    
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
    
    
    MBProgressHUD *progressIndic = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressIndic.mode = MBProgressHUDModeIndeterminate;
    
    __weak typeof(self) wSelf = self;
    
    [_viewModel downloadBehaviorAndReinforcersWithCompletion:^(NSError *error) {
       
        if (!error) {
            [lineChart reloadData];
            [wSelf updateData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
        [progressIndic hide:YES];
        
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
