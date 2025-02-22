//
//  ProfileViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProfileViewController.h"
#import "HomeViewController.h"


@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profileImageView.layer.cornerRadius = 5.0f;
    self.profileImageView.layer.borderWidth = 2.0f;
    self.profileImageView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.profileImageView.clipsToBounds = YES;
    
//    self.translucentView.hidden = YES;
    self.translucentView.backgroundColor = [UIColor clearColor];
    self.translucentView.translucentTintColor = [UIColor clearColor];
    self.translucentView.alpha = 0.9f;
    self.translucentView.translucentStyle = UIBarStyleBlack;
}

-(void)viewWillAppear:(BOOL)animated
{
    // KVO for profileImageView
    [self.profileImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];

    //[self setupLeftBackBarButtonItem];
    self.navigationController.navigationBar.hidden = YES;
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"profile_from_login" sender:self];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *name  = [currentUser objectForKey:@"name"];
    if (name == nil) {
        name = currentUser.username;
    }
    self.usernameLable.text = name;
    self.emailLable.text = currentUser.email;
    
    // Load profile image
    PFFile *imageFile = [[PFUser currentUser] objectForKey:@"profileImage"];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (imageFile != nil) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"error %@", error);
            if (!error) {
                if (data != nil) {
                    UIImage *image = [UIImage imageWithData:data];
                    self.profileImageView.image = image;
                }
            } else {
                NSLog(@"error %@", error);
            }
        } progressBlock:^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
            NSLog(@"percentDone %d", percentDone);
        }];
        
    } else {
        NSString *url = [[PFUser currentUser] objectForKey:@"profileImageURL"];
        if (url.length > 0) {
            [self loadAvatar:url withImage:self.profileImageView];
        }
        else {
            // load fb avatar
            NSString *userFBID = [[PFUser currentUser] objectForKey:@"fbId"];
            if (userFBID != nil) {
                [self loadfbAvatar:userFBID withImage:self.profileImageView];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    @try {
        [self.profileImageView removeObserver:self forKeyPath:@"image" context:NULL];
    }
    @catch (NSException *__unused exception) { }
}

- (void) observeValueForKeyPath:(NSString *)path ofObject:(id) object change:(NSDictionary *) change context:(void *)context
{
    // this method is used for all observations, so you need to make sure
    // you are responding to the right one.
    if (object == self.profileImageView && [path isEqualToString:@"image"])
    {
        // newImage is the image *after* the property changed
        UIImage *newImage = [change objectForKey:NSKeyValueChangeNewKey];
        
        // Set image of background
        if (newImage != NULL) {
            self.profileBgImageView.image = newImage;
        }
    }
}

- (void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Uploading";
    [HUD show:YES];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //Hide determinate HUD
            [HUD hide:YES];
            
            // Show checkmark
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            HUD.labelText = @"Completed";
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:5];
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFUser *user = [PFUser currentUser];
            [user setObject:imageFile forKey:@"profileImage"];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            [HUD hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        HUD.progress = (float)percentDone/100;
    }];
}

#pragma mark - Self action
- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (IBAction)backBtnClick:(id)sender {
    [self leftBackClick:nil];
}

- (IBAction)updateAvatarBtnClick:(UIButton*)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Update avatar profile" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheet.tag = sender.tag;
    [actionSheet showInView:self.view];
}

- (IBAction)defaultLocationClick:(UIButton*)sender {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"defaultLocationClick get location %@", geoPoint);
            // Update to current user
            PFUser *curUser = [PFUser currentUser];
            curUser[@"position"] = geoPoint;
            [curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    // save successful
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your location has been updated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }];
        }
        
    }];
    
}

- (IBAction)userfollowClick:(UIButton*)sender {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *gotImage = info[UIImagePickerControllerOriginalImage];
    self.profileImageView.image = gotImage;
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [gotImage drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData* data = UIImagePNGRepresentation(smallImage);
    [self uploadImage:data];
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
            UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
            pickerC.delegate = self;
            pickerC.view.tag = actionSheet.tag;
            pickerC.allowsEditing = true;
            [self presentViewController:pickerC animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"profile_from_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
    HUD = nil;
}

@end


