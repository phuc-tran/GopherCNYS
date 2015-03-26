//
//  SellViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SellViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SellViewController ()

@end

@implementation SellViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"add_product_from_login" sender:self];
    }
    
    self.productImageView.layer.cornerRadius = 5.0f;
    self.productImageView.layer.borderWidth = 2.0f;
    self.productImageView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImageView.clipsToBounds = YES;
}

- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)caputerBtnClick:(id)sender
{
    // 1
    UIAlertController *optionMenu = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    // 2
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                               {
                                                   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                   imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                   imagePicker.delegate = self;
                                                   imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
                                                   imagePicker.allowsEditing = false;
                                                   [self presentViewController:imagePicker animated:YES completion:nil];
                                                   
                                               }
                                           }];
    
    UIAlertAction *chooseExistingAction = [UIAlertAction actionWithTitle:@"Choose Existing"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
                                                                pickerC.delegate = self;
                                                                [self presentViewController:pickerC animated:YES completion:nil];
                                                            }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action) {
                                                                     // do destructive stuff here
                                                                 }];
    // 4
    [optionMenu addAction:takePhotoAction];
    [optionMenu addAction:chooseExistingAction];
    [optionMenu addAction:cancelAction];
    
    // 5
    [self.navigationController presentViewController:optionMenu animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *gotImage = info[UIImagePickerControllerOriginalImage];
    self.productImageView.image = gotImage;
    self.btnCapture.hidden = TRUE;
}

- (IBAction)handleTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)categoryBtnClick:(id)sender {
    SBPickerSelector *picker = [SBPickerSelector picker];
    NSArray *categoryData = [NSArray arrayWithObjects:@"All Categories", @"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    picker.pickerData = [[NSMutableArray alloc] initWithArray:categoryData];
    picker.delegate = self;
    picker.pickerType = SBPickerSelectorTypeText;
    picker.doneButtonTitle = @"Done";
    picker.cancelButtonTitle = @"Cancel";
    picker.tag = 100;
    [picker showPickerIpadFromRect:self.view.frame inView:self.view];
}

- (IBAction)conditionBtnClick:(id)sender {
    SBPickerSelector *picker = [SBPickerSelector picker];
    picker.pickerData = [[NSMutableArray alloc] initWithArray:@[@"New", @"Used"]];
    picker.delegate = self;
    picker.pickerType = SBPickerSelectorTypeText;
    picker.doneButtonTitle = @"Done";
    picker.cancelButtonTitle = @"Cancel";
    picker.tag = 200;
    [picker showPickerIpadFromRect:self.view.frame inView:self.view];
}

#pragma mark - SBPickerSelectorDelegate
-(void) pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx;
{
    if (selector.tag == 200) {
        [self.btnCondition setTitle:value forState:UIControlStateNormal];
    } else {
        [self.btnCategory setTitle:value forState:UIControlStateNormal];
    }
}
-(void) pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel {
    
}
@end
