//
//  ReinforcementCompViewController.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 10/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MAXOperantCondDataMan.h"

@interface ReinforcementCompViewController : UIViewController

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) MAXOperantCondDataMan *dataMan;

@end
