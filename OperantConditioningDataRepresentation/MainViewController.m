//
//  ViewController.m
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 03/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "MainViewController.h"
#import "ReinforcementScheduleDetailViewController.h"
#import "ReinforcementCompViewController.h"
#import "Chameleon.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "Constants.h"
#import "RandomUser.h"
#import "MAXOperantCondDataMan.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    NSArray *_users;
    
    MAXOperantCondDataMan *_dataMan;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _users = [NSArray array];
    
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    navBar.backgroundColor = [UIColor flatTealColor];
    [self.view addSubview:navBar];
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 80, 20, 160, CGRectGetHeight(navBar.frame) - 20)];
    navLabel.text = @"Overview";
    navLabel.textColor = [UIColor flatWhiteColor];
    navLabel.font = [UIFont maxwellBoldWithSize:19.0];
    navLabel.textAlignment = NSTextAlignmentCenter;
    [navBar addSubview:navLabel];
    
    UIButton *userButton = [UIButton buttonWithType:UIButtonTypeCustom];
    userButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 90, 20, 80, CGRectGetHeight(navBar.frame) - 20);
    userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    userButton.titleLabel.font = [UIFont maxwellBoldWithSize:17.0f];
    [userButton setTitleColor:[UIColor flatGreenColor] forState:UIControlStateNormal];
    [userButton setTitleColor:[UIColor flatGreenColorDark] forState:UIControlStateHighlighted];
    [userButton setTitle:@"Users" forState:UIControlStateNormal];
    [userButton addTarget:self action:@selector(userButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:userButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(navBar.frame)) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _dataMan = [[MAXOperantCondDataMan alloc] init];
    _users = _dataMan.users;
    
    /*
    MBProgressHUD *progressIndic = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressIndic.mode = MBProgressHUDModeIndeterminate;
    
    PFQuery *query = [PFQuery queryWithClassName:@"RandomUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [progressIndic hide:YES];
            
            if (!error) {
                _users = users;
                [_tableView reloadData];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
        });
        
    }];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)userButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"usersSegue" sender:self];
}

#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    
    cell.textLabel.textColor = [UIColor flatBlackColor];
    cell.textLabel.font = [UIFont openSansBoldWithSize:15.0f];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"All reinforcement schedules";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Fixed interval schedule";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Variable interval schedule";
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = @"Fixed ratio schedule";
    }
    else if (indexPath.row == 4) {
        cell.textLabel.text = @"Variable ratio schedule";
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= 1) {
        [self performSegueWithIdentifier:@"individualScheduleSegue" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"scheduleComparisonSegue" sender:self];
    }
    
}

-(NSArray*)usersForSchedule:(NSNumber*)theReinforcementSchedule {
    NSMutableArray *usersForSchedule = [NSMutableArray array];
    
    for (RandomUser *currentUser in _users) {
        if ([currentUser.reinforcementSchedule isEqual:theReinforcementSchedule]) {
            [usersForSchedule addObject:currentUser];
        }
    }
    
    return usersForSchedule;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"individualScheduleSegue"]) {
        
        ReinforcementScheduleDetailViewController *reinforcementVC = (ReinforcementScheduleDetailViewController*)[segue destinationViewController];
        
        reinforcementVC.randomUsers = _users;
        reinforcementVC.dataMan = _dataMan;
        
        int row = (int)[_tableView indexPathForSelectedRow].row;
        
        if (row == 1) {
            reinforcementVC.reinforcementSchedule = [NSNumber numberWithInt:kFISchedule];
            reinforcementVC.randomUsers = [self usersForSchedule:[NSNumber numberWithInt:kFISchedule]];
        }
        else if(row == 2) {
            reinforcementVC.reinforcementSchedule = [NSNumber numberWithInt:kVISchedule];
            reinforcementVC.randomUsers = [self usersForSchedule:[NSNumber numberWithInt:kVISchedule]];
        }
        else if(row == 3) {
            reinforcementVC.reinforcementSchedule = [NSNumber numberWithInt:kFRSchedule];
            reinforcementVC.randomUsers = [self usersForSchedule:[NSNumber numberWithInt:kFRSchedule]];
        }
        else if(row == 4) {
            reinforcementVC.reinforcementSchedule = [NSNumber numberWithInt:kVRSchedule];
            reinforcementVC.randomUsers = [self usersForSchedule:[NSNumber numberWithInt:kVRSchedule]];
        }
    }
    else if([segue.identifier isEqualToString:@"scheduleComparisonSegue"]) {
        
        ReinforcementCompViewController *compVC = (ReinforcementCompViewController*)[segue destinationViewController];
        compVC.users = _users;
        compVC.dataMan = _dataMan;
        
    }
    
}

@end
