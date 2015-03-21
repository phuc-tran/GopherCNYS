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
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

-(void)leftMenuClick:(UIBarButtonItem*)btn
{
    [self.sideMenuViewController presentLeftMenuViewController];
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


@end
