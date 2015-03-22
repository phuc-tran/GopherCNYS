//
//  ProfileViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftMenuBarButtonItem];
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"profile_from_login" sender:self];
    }
}

- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
