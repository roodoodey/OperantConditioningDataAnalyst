//
//  ReinforcementScheduleDetailViewController.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 15/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MAXOperantCondDataMan.h"

@interface ReinforcementScheduleDetailViewController : UIViewController

@property (nonatomic, strong) NSArray *randomUsers;
@property (nonatomic, strong) NSNumber *reinforcementSchedule;

@property (nonatomic, strong) MAXOperantCondDataMan *dataMan;

@end
