//
//  UsersOverviewViewController.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UsersOverviewViewController.h"
#import "Chameleon.h"
#import "MBProgressHUD.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import <Parse/Parse.h>
#import "UsersOverviewViewModel.h"
#import "UserDetailViewController.h"

@interface UsersOverviewViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    UsersOverviewViewModel *_viewModel;
}

@end

@implementation UsersOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewModel = [[UsersOverviewViewModel alloc] init];
    
    // Do any additional setup after loading the view.
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
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 80, 20, 160, CGRectGetHeight(navBar.frame) - 20)];
    navLabel.text = @"Participants";
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.textColor = [UIColor flatWhiteColor];
    navLabel.font = [UIFont maxwellBoldWithSize:19.0];
    [navBar addSubview:navLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(navBar.frame)) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
        
    MBProgressHUD *progressIndic = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressIndic.mode = MBProgressHUDModeIndeterminate;
    
    [_viewModel downloadRandomUsersWithBlock:^(BOOL success, NSError *error) {
        
        if (!error) {
            [progressIndic hide:true];
            [_tableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Delegate & Data Source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"FI Schedule";
    }
    else if (section == 1) {
        return @"VI schedule";
    }
    else if (section == 2) {
        return @"FR schedule";
    }
    else if (section == 3) {
        return @"VR schedule";
    }
    
    return @"Unknown schedule";
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *headerName = [[tableView dataSource] tableView:tableView titleForHeaderInSection:section];
    CGFloat headerHeight = [[tableView delegate] tableView:tableView heightForHeaderInSection:section];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    header.backgroundColor = [UIColor flatGrayColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), headerHeight)];
    headerLabel.text = headerName;
    headerLabel.font = [UIFont openSansBoldWithSize:15.0];
    headerLabel.textColor = [UIColor flatWhiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    [header addSubview:headerLabel];
    
    return header;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_viewModel numberOfSections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_viewModel numberOfRowsInSection:section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    
    cell.textLabel.text = [_viewModel userIdAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont openSansBoldWithSize:15.0];
    
    if ([_viewModel isUserExcludedAtIndexPath:indexPath]) {
        cell.textLabel.textColor = [UIColor flatGrayColor];
    }
    else {
        cell.textLabel.textColor = [UIColor flatBlackColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"userDetailSegue" sender:self];
    
    /*
    [_viewModel excludeOrAddUserDataAtIndexPath:indexPath withCompletion:^(BOOL excluded) {
        if (excluded) {
            cell.textLabel.textColor = [UIColor flatGrayColor];
        }
        else {
            cell.textLabel.textColor = [UIColor flatBlackColor];
        }
    }];
    */
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UserDetailViewController *detailVC = (UserDetailViewController*)segue.destinationViewController;
    
    detailVC.randomUser = [_viewModel userAtIndexPath:_tableView.indexPathForSelectedRow];
    
    
}


@end
