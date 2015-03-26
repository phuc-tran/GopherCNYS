//
//  SellViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SBPickerSelector.h"

@interface SellViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SBPickerSelectorDelegate>

- (IBAction)pushViewController:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnCondition;

@end
