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

@class GPPSignInButton;

@interface HomeViewController : UIViewController <GPPSignInDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIButton *facebookButon;
@property (retain, nonatomic) IBOutlet UIButton *gPlusButton;

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIView *viewLogin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLoginTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgTopConstraint;

-(IBAction) signIn:(id)sender;

@property UIActivityIndicatorView *activityIndicator;

@end

