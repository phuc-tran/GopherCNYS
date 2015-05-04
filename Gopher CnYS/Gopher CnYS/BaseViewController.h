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
#import <SDWebImage/UIImageView+WebCache.h>
#import "GlobalHeard.h"

@interface BaseViewController : UIViewController
{
    
}

@property (nonatomic, assign) NSInteger menuSelectedIndex;


- (void)setupMenuBarButtonItems;
- (void)setupLeftMenuBarButtonItem;
- (void)setupRightMenuBarButtonItem;
- (void)setupLeftBackBarButtonItem;

-(void)leftMenuClick:(UIBarButtonItem*)btn;
-(void)leftBackClick:(UIBarButtonItem*)btn;

-(BOOL) checkIfUserLoggedIn;
- (void)loadAvatar:(NSString*)strUrl withImage:(UIImageView*)avatarImage;
- (void)loadfbAvatar:(NSString *)fbID withImage:(UIImageView *)avatarImage;

@end
