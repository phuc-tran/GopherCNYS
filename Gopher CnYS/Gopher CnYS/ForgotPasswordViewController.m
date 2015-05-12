//
//  ForgotPasswordViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/13/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import <Parse/Parse.h>
#import "ProductListViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

#pragma mark - Self View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)sendButton:(id)sender
{
    NSString *email = _txtEmail.text;
    
    if (email.length <= 0) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"We will send you password reset email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@", errorString);
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
