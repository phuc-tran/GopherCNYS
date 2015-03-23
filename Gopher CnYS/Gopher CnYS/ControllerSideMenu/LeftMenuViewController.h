//
//  LeftMenuViewController.h
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "BaseViewController.h"

@interface LeftMenuViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate, UIAlertViewDelegate>

@end