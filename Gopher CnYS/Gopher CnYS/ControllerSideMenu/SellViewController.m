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
#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CLPlacemark+ShortState.h"

@interface SellViewController ()
{
    SBPickerSelector *pickerCategory;
    NSArray *categoryData ;
    
    SBPickerSelector *pickerCondition;
}
@end

@implementation SellViewController

@synthesize isEdit;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"addproduct_form_login" sender:self];
    }    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            currentLocaltion = geoPoint;
        }
        NSLog(@"get location %@", currentLocaltion);
    }];
    
    pickerCondition = [SBPickerSelector picker];
    categoryId = 0;
    pickerCategory = [SBPickerSelector picker];
    categoryData = [NSArray arrayWithObjects:@"All Categories", @"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
    
    self.productImageView1.layer.cornerRadius = 5.0f;
    self.productImageView1.layer.borderWidth = 2.0f;
    self.productImageView1.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImageView1.clipsToBounds = YES;
    
    self.productImageView2.layer.cornerRadius = 5.0f;
    self.productImageView2.layer.borderWidth = 2.0f;
    self.productImageView2.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImageView2.clipsToBounds = YES;
    
    self.productImageView3.layer.cornerRadius = 5.0f;
    self.productImageView3.layer.borderWidth = 2.0f;
    self.productImageView3.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImageView3.clipsToBounds = YES;
    
    self.productImageView4.layer.cornerRadius = 5.0f;
    self.productImageView4.layer.borderWidth = 2.0f;
    self.productImageView4.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImageView4.clipsToBounds = YES;
    if(isEdit) {
        if(self.productInfo != nil) {
            [self.addProductBtn setTitle:@"Save product" forState:UIControlStateNormal];

            PFFile *imageFile = [self.productInfo objectForKey:@"photo1"];
            if (imageFile != nil) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.productImageView1.image = image;
                        [self.btnCapture1 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
                        [self.btnCapture1 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
                    }
                }];
            }
            
            imageFile = [self.productInfo objectForKey:@"photo2"];
            if (imageFile != nil) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.productImageView2.image = image;
                        [self.btnCapture2 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
                        [self.btnCapture2 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
                    }
                }];
            }
            
            imageFile = [self.productInfo objectForKey:@"photo3"];
            if (imageFile != nil) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.productImageView3.image = image;
                        [self.btnCapture3 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
                        [self.btnCapture3 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
                    }
                }];
            }
            
            imageFile = [self.productInfo objectForKey:@"photo4"];
            if (imageFile != nil) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.productImageView4.image = image;
                        [self.btnCapture4 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
                        [self.btnCapture4 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
                    }
                }];
            }
            
            self.productTitleField.text = self.productInfo.title;
            self.productDescriptionField.text = [[self.productInfo objectForKey:@"description"] description];
            NSInteger price  = [self.productInfo.price integerValue];
            self.productPriceField.text = [NSString stringWithFormat:@"%ld", (long)price];
            bool condition = self.productInfo.condition;
            [self.btnCondition setTitle:((condition == true) ? @"New" : @"Used") forState:UIControlStateNormal];
            conditionId = ((condition == true) ? 0 : 1);
           
            [pickerCondition.pickerView selectRow:conditionId inComponent:0 animated:YES];
            NSInteger quantity = [self.productInfo.quantity integerValue];
            self.productQuatityField.text = [NSString stringWithFormat:@"%ld", (long)quantity];
            
            NSInteger category = [self.productInfo.category integerValue];
            categoryId = category;
            [pickerCondition.pickerView selectRow:category inComponent:0 animated:YES];
            [self.btnCategory setTitle:categoryData[category] forState:UIControlStateNormal];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    
    
}

- (IBAction)leftBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"add_product_from_login"]) {
//        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
//        destViewController.shouldGoBack = YES;
//    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
        NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    
    // stop updating location in order to save battery power
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
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
                 strAdd = placemark.shortState;
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
    
    if (![self validationInput]) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFObject *product = [PFObject objectWithClassName:@"Products"];
    if (imageFile1 != nil) {
        product[@"photo1"] = imageFile1;
    }
    
    if (imageFile2 != nil) {
        product[@"photo2"] = imageFile2;
    }
    
    if (imageFile3 != nil) {
        product[@"photo3"] = imageFile3;
    }
    
    if (imageFile4 != nil) {
        product[@"photo4"] = imageFile4;
    }
    
    product[@"title"] = self.productTitleField.text;
    product[@"description"] = self.productDescriptionField.text;
    product[@"category"] = @(categoryId);
    BOOL condition = (conditionId == 0);
    product[@"condition"] = @(condition);
    product[@"deleted"] = @NO;
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Product has been listed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = 1;
            [alert show];
        } else {
            NSLog(@"Error %@", error);
            // There was a problem, check error.description
        }
    }];
}

- (void)editProduct {
    
    if (![self validationInput]) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (imageFile1 != nil) {
        self.productInfo.photo1 = imageFile1;
    }
    
    if (imageFile2 != nil) {
        self.productInfo.photo2 = imageFile2;
    }
    
    if (imageFile3 != nil) {
        self.productInfo.photo3 = imageFile3;
    }
    
    if (imageFile4 != nil) {
        self.productInfo.photo4 = imageFile4;
    }
    
    self.productInfo.title = self.productTitleField.text;
    self.productInfo[@"description"] = self.productDescriptionField.text;
    self.productInfo.category = @(categoryId);
    BOOL condition = (conditionId == 0);
    self.productInfo[@"condition"] = @(condition);
    self.productInfo[@"deleted"] = @NO;
    NSLog(@"price  %@", self.productPriceField.text);
    self.productInfo.price = @([self.productPriceField.text integerValue]);
    self.productInfo.quantity = @([self.productQuatityField.text integerValue]);
    self.productInfo[@"seller"] = [PFUser currentUser];
    
    if (currentLocaltion != nil) {
        self.productInfo[@"position"] = currentLocaltion;
    }
    if (adminAreaStr != nil) {
        self.productInfo[@"adminArea"] = adminAreaStr;
    }
    if (countryStr != nil) {
        self.productInfo[@"country"] = countryStr;
    }
    if (localityStr != nil) {
        self.productInfo[@"locality"] = localityStr;
    }
    if (postalCodeStr != nil) {
        self.productInfo[@"postalCode"] = postalCodeStr;
    }
    
    
    [self.productInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            // The object has been saved.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Product edit success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = 1;
            [alert show];
        } else {
            NSLog(@"Error %@", error);
            // There was a problem, check error.description
        }
    }];
}

- (BOOL) validationInput {
    if (self.productImageView1.image == nil && self.productImageView2.image == nil && self.productImageView3.image == nil && self.productImageView3.image == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select at least one product picture" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if (self.productTitleField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input product title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if (self.productDescriptionField.text.length <= 0 || [self.productDescriptionField.text isEqualToString:@"Product Description"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input product description" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if (categoryId <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please choose category for product" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if (self.productPriceField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input product price" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if (self.productQuatityField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input product quantity" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    return YES;
}
#pragma mark - Seft action

- (IBAction)addProductBtnClick:(id)sender {
    if (self.isEdit && self.productInfo != nil) {
        [self editProduct];
    } else {
        [self addProduct];
    }
}

- (IBAction)caputerBtnClick:(UIButton*)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Upload product image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheet.tag = sender.tag;
    [actionSheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *gotImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [editImage drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    switch (picker.view.tag) {
        case 1:
        {
            self.productImageView1.image = gotImage;
            [self.btnCapture1 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
            [self.btnCapture1 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
            NSData *imageData = UIImagePNGRepresentation(smallImage);
            imageFile1 = [PFFile fileWithName:@"productImage1.png" data:imageData];
            [imageFile1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"product 1 upload success");
                } else {
                    NSLog(@"Error %@", [error userInfo]);
                }
            }];
        }
            break;
        case 2:
        {
            self.productImageView2.image = gotImage;
            [self.btnCapture2 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
            [self.btnCapture2 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
            NSData *imageData = UIImagePNGRepresentation(smallImage);
            imageFile2 = [PFFile fileWithName:@"productImage2.png" data:imageData];
            [imageFile2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"product 2 upload success");
                } else {
                    NSLog(@"Error %@", [error userInfo]);
                }
            }];
        }
            break;
        case 3:
        {
            self.productImageView3.image = gotImage;
            [self.btnCapture3 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
            [self.btnCapture3 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
            NSData *imageData = UIImagePNGRepresentation(smallImage);
            imageFile3 = [PFFile fileWithName:@"productImage3.png" data:imageData];
            [imageFile3 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"product 3 upload success");
                } else {
                    NSLog(@"Error %@", [error userInfo]);
                }
            }];
        }
            break;
        case 4:
        {
            self.productImageView4.image = gotImage;
            [self.btnCapture4 setImage:[UIImage imageNamed:@"icon_capture.png"] forState:UIControlStateNormal];
            [self.btnCapture4 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -50, 0)];
            NSData *imageData = UIImagePNGRepresentation(smallImage);
            imageFile4 = [PFFile fileWithName:@"productImage4.png" data:imageData];
            [imageFile4 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"product 4 upload success");
                } else {
                    NSLog(@"Error %@", [error userInfo]);
                }
            }];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)handleTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)categoryBtnClick:(id)sender {
    [self.view endEditing:true];
    pickerCategory.pickerData = [[NSMutableArray alloc] initWithArray:categoryData];
    pickerCategory.delegate = self;
    pickerCategory.pickerType = SBPickerSelectorTypeText;
    pickerCategory.doneButtonTitle = @"Done";
    pickerCategory.cancelButtonTitle = @"Cancel";
    pickerCategory.tag = 100;
    [pickerCategory showPickerIpadFromRect:self.view.frame inView:self.view];
}

- (IBAction)conditionBtnClick:(id)sender {
    [self.view endEditing:true];
    pickerCondition.pickerData = [[NSMutableArray alloc] initWithArray:@[@"New", @"Used"]];
    pickerCondition.delegate = self;
    pickerCondition.pickerType = SBPickerSelectorTypeText;
    pickerCondition.doneButtonTitle = @"Done";
    pickerCondition.cancelButtonTitle = @"Cancel";
    pickerCondition.tag = 200;
    [pickerCondition showPickerIpadFromRect:self.view.frame inView:self.view];
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
                imagePicker.allowsEditing = true;
                imagePicker.view.tag = actionSheet.tag;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
            break;
        case 1: //Choose Existing
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = true;
                imagePicker.view.tag = actionSheet.tag;
                [self presentViewController:imagePicker animated:YES completion:nil];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Product Description"]) {
        textView.text = @"";
    }
    [textView becomeFirstResponder];

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] || [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <=0) {
        textView.text = @"Product Description";
    }
    [textView resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)sender
{
    self.activeField = sender;
}

- (void)textFieldDidEndEditing:(UITextField *)sender
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

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (alertView.tag == 1 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UICollectionViewDelegate

@end
