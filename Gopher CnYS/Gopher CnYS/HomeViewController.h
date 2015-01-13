//
//  ViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 12/24/14.
//  Copyright (c) 2014 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPPSignInButton;

@interface HomeViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *facebookButon;
@property (retain, nonatomic) IBOutlet UIButton *signinButton;
@property (retain, nonatomic) IBOutlet GPPSignInButton *gPlusButton;
@property (retain, nonatomic) IBOutlet UIView *createAccountButton;

@end

