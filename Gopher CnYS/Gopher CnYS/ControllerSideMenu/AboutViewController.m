//
//  MessagesViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "AboutViewController.h"
#import "HomeViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"about_from_login" sender:self];
    }
}

- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"about_from_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = NO;
    }
}

- (IBAction)facebookClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@" https://www.facebook.com/groups/GopherCnYs/"]];
}

- (IBAction)twiterClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/GopherCnYS"]];
}

- (IBAction)googlePlusClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://plus.google.com/communities/108134363430080385476?cfem=1"]];
}

- (IBAction)websiteClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.gopherclassifieds.com"]];
}

@end
