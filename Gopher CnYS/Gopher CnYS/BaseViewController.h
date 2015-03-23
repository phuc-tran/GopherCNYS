//
//  BaseViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface BaseViewController : UIViewController

- (void)setupMenuBarButtonItems;
- (void)setupLeftMenuBarButtonItem;
- (void)setupRightMenuBarButtonItem;
- (void)setupLeftBackBarButtonItem;
-(void)leftMenuClick:(UIBarButtonItem*)btn;

-(BOOL) checkIfUserLoggedIn;

@end
