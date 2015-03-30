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
#import <AVFoundation/AVFoundation.h>
#import "ProductImageCollectionViewCell.h"

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"add_product_from_login" sender:self];
    }
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
    PFObject *product = [PFObject objectWithClassName:@"Products"];
    
    if (self.productImageView1.image != nil) {
        NSData *imageData = UIImagePNGRepresentation(self.productImageView1.image);
        PFFile *imageFile = [PFFile fileWithName:@"productImage1.png" data:imageData];
        product[@"photo1"] = imageFile;
    }
    
    if (self.productImageView2.image != nil) {
        NSData *imageData = UIImagePNGRepresentation(self.productImageView2.image);
        PFFile *imageFile = [PFFile fileWithName:@"productImage2.png" data:imageData];
        product[@"photo2"] = imageFile;
    }
    
    if (self.productImageView3.image != nil) {
        NSData *imageData = UIImagePNGRepresentation(self.productImageView3.image);
        PFFile *imageFile = [PFFile fileWithName:@"productImage3.png" data:imageData];
        product[@"photo3"] = imageFile;
    }
    
    if (self.productImageView4.image != nil) {
        NSData *imageData = UIImagePNGRepresentation(self.productImageView4.image);
        PFFile *imageFile = [PFFile fileWithName:@"productImage4.png" data:imageData];
        product[@"photo4"] = imageFile;
    }
    
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
    switch (picker.view.tag) {
        case 1:
            self.productImageView1.image = gotImage;
            self.btnCapture1.hidden = TRUE;
            break;
        case 2:
            self.productImageView2.image = gotImage;
            self.btnCapture2.hidden = TRUE;
            break;
        case 3:
            self.productImageView3.image = gotImage;
            self.btnCapture3.hidden = TRUE;
            break;
        case 4:
            self.productImageView4.image = gotImage;
            self.btnCapture4.hidden = TRUE;
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
                imagePicker.view.tag = actionSheet.tag;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
            break;
        case 1: //Choose Existing
            {
                UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
                pickerC.delegate = self;
                pickerC.view.tag = actionSheet.tag;
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] || [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        [textView setText:@""];
    }
}

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

#pragma mark - UzysAssetsPickerControllerDelegate methods
//- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
//{
//    //self.productImageView.backgroundColor = [UIColor clearColor];
//    DLog(@"assets %ld",(unsigned long)assets.count);
//    __weak typeof(self) weakSelf = self;
//    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
//    {
//        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            ALAsset *representation = obj;
//            
//            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
//                                               scale:representation.defaultRepresentation.scale
//                                         orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
//            //weakSelf.productImageView.image = img;
//            gotImage = img;
//            *stop = YES;
//        }];
//        
//        
//    }
//}

#pragma mark - UICollectionViewDelegate

//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    //NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
//    return 4;
//}
//
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    // Setup cell identifier
//    static NSString *cellIdentifier = @"productImageCell";
//    ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.productImageView.backgroundColor = [UIColor clearColor];
//    if (gotImage != nil) {
//        cell.productImageView.image = gotImage;
//    }
//    // Return the cell
//    return cell;
//    
//}
@end
