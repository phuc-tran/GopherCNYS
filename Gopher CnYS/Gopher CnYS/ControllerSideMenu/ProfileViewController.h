//
//  ProfileViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface ProfileViewController : BaseViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MBProgressHUDDelegate>
{
     MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLable;
@property (weak, nonatomic) IBOutlet UILabel *emailLable;

- (IBAction)pushViewController:(id)sender;

- (IBAction)defaultLocationClick:(UIButton*)sender;

- (IBAction)userfollowClick:(UIButton*)sender;

@end
