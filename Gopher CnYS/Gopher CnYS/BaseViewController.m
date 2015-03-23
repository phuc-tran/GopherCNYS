//
//  BaseViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMenuBarButtonItems {
    [self setupLeftMenuBarButtonItem];
    [self setupRightMenuBarButtonItem];
}

- (void)setupLeftMenuBarButtonItem {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

- (void)setupLeftBackBarButtonItem {
    self.navigationItem.leftBarButtonItem = [self leftBackBarButtonItem];
}

- (void)setupRightMenuBarButtonItem {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

-(void)leftMenuClick:(UIBarButtonItem*)btn
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)leftBackClick:(UIBarButtonItem*)btn
{
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"productListViewController"]]
                                                                                                           animated:YES];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 setFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
    [a1 setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:a1];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIImage *buttonImage = [UIImage imageNamed:@"menu-icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [button addTarget:self action:@selector(leftMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (UIBarButtonItem *)leftBackBarButtonItem {
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [button addTarget:self action:@selector(leftBackClick:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(BOOL) checkIfUserLoggedIn
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        return YES;
    }
    return NO;
}

@end
