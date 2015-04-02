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
#import "UzysAssetsPickerController.h"

@interface SellViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SBPickerSelectorDelegate, UITextViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>
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
    
    PFFile *imageFile1;
    PFFile *imageFile2;
    PFFile *imageFile3;
    PFFile *imageFile4;
}

- (IBAction)pushViewController:(id)sender;

@property (nonatomic, assign) BOOL isFromTabBar;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture1;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView1;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture2;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView2;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture3;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView3;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture4;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView4;

@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnCondition;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (weak, nonatomic) IBOutlet UITextField *productTitleField;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *productPriceField;
@property (weak, nonatomic) IBOutlet UITextField *productQuatityField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIButton *addproductBtn;

- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardDidHide:(NSNotification *)note;

@end
