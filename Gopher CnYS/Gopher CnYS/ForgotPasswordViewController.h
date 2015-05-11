//
//  ForgotPasswordViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/13/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

-(IBAction)sendButton:(id)sender;

@end
