//
//  ViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 12/24/14.
//  Copyright (c) 2014 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"
#import "BaseViewController.h"

@class GPPSignInButton;

@interface HomeViewController : BaseViewController <GPPSignInDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIButton *facebookButon;
@property (retain, nonatomic) IBOutlet UIButton *gPlusButton;

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) UITextField *activeField;
@property (nonatomic, assign) BOOL shouldGoBack;

-(IBAction) signIn:(id)sender;
-(IBAction) cancelClick:(id)sender;

@property UIActivityIndicatorView *activityIndicator;


@end

