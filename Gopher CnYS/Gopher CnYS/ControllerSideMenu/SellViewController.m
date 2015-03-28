//
//  SellViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SellViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"

@interface SellViewController ()

@end

@implementation SellViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            currentLocaltion = geoPoint;
        }
        NSLog(@"get location %@", currentLocaltion);
    }];
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
}

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

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"UIKeyboardWillShowNotification"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"UIKeyboardDidHideNotification"];
}

- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
   // CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
        NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    
    // stop updating location in order to save battery power
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             
             // strAdd -> take bydefault value nil
             NSString *strAdd = nil;
             
             if ([placemark.subThoroughfare length] != 0) {
                 strAdd = placemark.subThoroughfare;
                 NSLog(@"subThoroughfare %@", strAdd);
             }
             
             if ([placemark.thoroughfare length] != 0) {
                 strAdd = placemark.thoroughfare;
                 NSLog(@"thoroughfare %@", strAdd);
             }
             
             if ([placemark.postalCode length] != 0) {
                 strAdd = placemark.postalCode;
                 postalCodeStr = strAdd;
                 NSLog(@"postalCodeStr %@", postalCodeStr);
             }
             
             if ([placemark.locality length] != 0) {
                 strAdd = placemark.locality;
                 localityStr = strAdd;
                 NSLog(@"localityStr %@", localityStr);
             }
             
             if ([placemark.administrativeArea length] != 0) {
                 strAdd = placemark.administrativeArea;
                 adminAreaStr = strAdd;
                  NSLog(@"adminAreaStr %@", adminAreaStr);
             }
             
             if ([placemark.country length] != 0) {
                 strAdd = placemark.country;
                 countryStr = strAdd;
                NSLog(@"countryStr %@", countryStr);
             }

         }
    }];
}
     
#pragma mark - Helper
- (void)addProduct {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSData *imageData = UIImagePNGRepresentation(self.productImageView.image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
    PFObject *product = [PFObject objectWithClassName:@"Products"];
    product[@"photo1"] = imageFile;
    product[@"title"] = self.productTitleField.text;
    product[@"description"] = self.productDescriptionField.text;
    product[@"category"] = @(categoryId);
    BOOL condition = (conditionId == 0);
    product[@"condition"] = @(condition);
    product[@"price"] = @([self.productPriceField.text integerValue]);
    product[@"quantity"] = @([self.productQuatityField.text integerValue]);
    product[@"seller"] = [PFUser currentUser];
    if (currentLocaltion != nil) {
        product[@"position"] = currentLocaltion;
    }
    if (adminAreaStr != nil) {
        product[@"adminArea"] = adminAreaStr;
    }
    if (countryStr != nil) {
        product[@"country"] = countryStr;
    }
    if (localityStr != nil) {
        product[@"locality"] = localityStr;
    }
    if (postalCodeStr != nil) {
        product[@"postalCode"] = postalCodeStr;
    }
    
    [product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            // The object has been saved.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Add product successful" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            NSLog(@"Error %@", error);
            // There was a problem, check error.description
        }
    }];
    
}
#pragma mark - Seft action

- (IBAction)addProductBtnClick:(id)sender {
    [self addProduct];
}

- (IBAction)caputerBtnClick:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Upload product image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [actionSheet showInView:self.view];
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
    [self.view endEditing:true];
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
    [self.view endEditing:true];
    SBPickerSelector *picker = [SBPickerSelector picker];
    picker.pickerData = [[NSMutableArray alloc] initWithArray:@[@"New", @"Used"]];
    picker.delegate = self;
    picker.pickerType = SBPickerSelectorTypeText;
    picker.doneButtonTitle = @"Done";
    picker.cancelButtonTitle = @"Cancel";
    picker.tag = 200;
    [picker showPickerIpadFromRect:self.view.frame inView:self.view];
}
#pragma mark - UIActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button at index: %ld clicked\nIts title is '%@'", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    switch (buttonIndex) {
        case 0: // Take photo
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
                imagePicker.allowsEditing = false;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
            break;
        case 1: //Choose Existing
            {
                UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
                pickerC.delegate = self;
                [self presentViewController:pickerC animated:YES completion:nil];
            }
            break;
        default:
            break;
    }
}


#pragma mark - SBPickerSelectorDelegate
-(void) pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx;
{
    if (selector.tag == 200) {
        [self.btnCondition setTitle:value forState:UIControlStateNormal];
        conditionId = idx;
    } else {
        [self.btnCategory setTitle:value forState:UIControlStateNormal];
        categoryId = idx;
    }
}
-(void) pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel {
    
}
#pragma mark - UITextViewDelegate

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender
{
    self.activeField = sender;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    self.activeField = nil;
}

#pragma mark - Keyboard Handler
- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.contentScrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void) keyboardDidHide:(NSNotification *)note {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
}
@end
