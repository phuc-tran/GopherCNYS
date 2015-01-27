//
//  SigninViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/13/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SigninViewController.h"
#import <Parse/Parse.h>
#import "ProductListViewController.h"

@interface SigninViewController ()

@end

@implementation SigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) openProductList
{
    [self performSegueWithIdentifier:@"product_list_from_sign_in" sender:self];
    //ProductListViewController *productListViewController = [[ProductListViewController alloc] init];
    //[self.navigationController pushViewController:productListViewController animated:YES];
}

-(IBAction)signIn:(id)sender
{
    NSString *userName = _txtUserName.text;
    NSString *password = _txtPassword.text;
    
    if (userName.length <= 0) {
        return;
    } else if (password.length <= 0) {
        return;
    }
    
    [PFUser logInWithUsernameInBackground:userName password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            NSLog(@"Login OK");
                                            [self openProductList];
                                        } else {
                                            NSLog(@"Failed");
                                        }
                                    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
