//
//  CreateAccountViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/13/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "CreateAccountViewController.h"
#import <Parse/Parse.h>
#import "ProductListViewController.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

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



-(IBAction)register:(id)sender
{
    NSString *userName = _txtUserName.text;
    NSString *password = _txtPassword.text;
    NSString *email = _txtEmail.text;
    
    if (userName.length <= 0) {
        return;
    } else if (email.length <= 0) {
        return;
    } else if (password.length <= 0) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *user = [PFUser user];
    user.username = userName;
    user.password = password;
    user.email = email;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error) {
                    NSLog(@"Facebook get location %@", geoPoint);
                    // Update to current user
                    PFUser *curUser = [PFUser currentUser];
                    curUser[@"position"] = geoPoint;
                    [curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        if (succeeded) {
                            // save successful
                            [self openProductList];
                           
                        }
                    }];
                }
                
            }];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@", errorString);
        }
    }];
}


-(void) openProductList
{
    [self.navigationController popViewControllerAnimated:YES];
    //[self performSegueWithIdentifier:@"product_list_from_sign_up" sender:self];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
