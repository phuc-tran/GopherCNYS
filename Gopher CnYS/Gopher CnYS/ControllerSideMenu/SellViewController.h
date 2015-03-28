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
#import <Parse/Parse.h>

@interface SellViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SBPickerSelectorDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>
{
    NSUInteger categoryId;
    NSUInteger conditionId;
    PFGeoPoint *currentLocaltion;
    CLLocationManager *locationManager;
    NSString *countryStr;
    NSString *localityStr;
    NSString *adminAreaStr;
    NSString *postalCodeStr;
    NSString *subLocalityStr;
    NSString *subAdminAreaStr;

}

- (IBAction)pushViewController:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnCondition;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (weak, nonatomic) IBOutlet UITextField *productTitleField;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *productPriceField;
@property (weak, nonatomic) IBOutlet UITextField *productQuatityField;

@property (weak, nonatomic) UITextField *activeField;

- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardDidHide:(NSNotification *)note;

@end
