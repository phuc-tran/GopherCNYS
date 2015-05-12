//
//  ViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 12/24/14.
//  Copyright (c) 2014 cnys. All rights reserved.
//

#import "HomeViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ProductListViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>


@interface HomeViewController () <GPPSignInDelegate>

@end

@implementation HomeViewController

static NSString * const kClientId = @"27474982896-5b5a9a73q19res441a3niie8e3mi7jlr.apps.googleusercontent.com";

#pragma mark - Self View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    if ([self checkIfUserLoggedIn])
    {
        
        if (![[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please verify your email first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [PFUser logOut];
            return;
        }
        NSLog(@"User has logged. Let's load data");
        [self openProductList];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:@"UIKeyboardWillShowNotification"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"UIKeyboardDidHideNotification"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) gpSignInEnable {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    //signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
}

-(void) openProductList
{
    if (!self.shouldGoBack) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"productListViewController"]]
                                                     animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void) loadUI
{
    // Background
    UIImage *imageBackground = [UIImage imageNamed:@"background.png"];
    
    CGSize size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);//set the width and height
    UIImage *resizedImage= [self resizeImage:imageBackground imageSize:size];
    
    UIImageView *ivBackground = [[UIImageView alloc] initWithImage:resizedImage];
    ivBackground.translatesAutoresizingMaskIntoConstraints = NO;
    ivBackground.frame = self.view.frame;
    [self.view addSubview:ivBackground];
}

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
    
}

-(IBAction)facebookButtonPressed:(id)sender
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        [_activityIndicator stopAnimating];
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
//                                                            message:errorMessage
//                                                           delegate:nil
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:@"Dismiss", nil];
//            [alert show];
        } else {
            
            [self openProductList];
            
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSString *facebookUsername = [result objectForKey:@"name"];
                    [PFUser currentUser].username = facebookUsername;
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
                    [[PFUser currentUser] setObject:facebookUsername forKey:@"name"];
                    NSNumber *userType = [[NSNumber alloc] initWithInt:1];
                    [[PFUser currentUser] setObject:userType forKey:@"userType"];
                    [[PFUser currentUser] saveEventually];
                    
                    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                        if (!error) {
                            NSLog(@"Facebook get location %@", geoPoint);
                            // Update to current user
                            PFUser *curUser = [PFUser currentUser];
                            curUser[@"position"] = geoPoint;
                            [curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                if (succeeded) {
                                    // save successful
                                }
                            }];
                        }
                        
                    }];
                    
                } else {
                    NSLog(@"Error getting the FB username %@", [error description]);
                }
            }];
            
            [self addUserToParseBackend:[PFUser currentUser]];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void) addUserToParseBackend: (PFUser *)user
{
    NSLog(@"addUserToParseBackend");
    if (user)
    {
        NSLog(@"%@", [user username]);
        NSLog(@"%@", [user objectId]);
        NSLog(@"%@", [user email]);
        
        NSLog(@"%@", [user objectForKey:@"*"] );
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                NSLog(@"addUserToParseBackend --- OK");
            }
            else
            {
                NSLog(@"addUserToParseBackend --- Error: %@", [error description]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:@"There's an error with log in. Please try again"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            
        }];
        
        // Add user to PFInstallation
        [[PFInstallation currentInstallation] setObject:user forKey:@"user"];
        [[PFInstallation currentInstallation] saveEventually];
    }
}


-(IBAction)signIn:(id)sender
{
    [self.view endEditing:TRUE];
    
    NSString *userName = _txtUserName.text;
    NSString *password = _txtPassword.text;
    
    if (userName.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input user name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    } else if (password.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            if (objects.count > 0) {
                PFUser *user = objects[0];
                if (![[user objectForKey:@"emailVerified"] boolValue]) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please verify your email first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                } else {
                    [PFUser logInWithUsernameInBackground:userName password:password
                                                    block:^(PFUser *user, NSError *error) {
                                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                        if (user) {
                                                            NSLog(@"Login OK");
                                                            
                                                            // Add user to PFInstallation
                                                            [[PFInstallation currentInstallation] setObject:user forKey:@"user"];
                                                            [[PFInstallation currentInstallation] saveEventually];
                                                            
                                                            [self openProductList];
                                                        } else {
                                                            NSLog(@"Failed");
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Invalid username or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                            [alert show];
                                                        }
                                                    }];
                }
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
    
    return;
    
    
}

-(IBAction) cancelClick:(id)sender {
    
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"productListViewController"]]
                                                 animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUserName) {
        [self.txtPassword becomeFirstResponder];
    } else if (textField == self.txtPassword) {
        [self signIn:self.btnSignIn];
    }
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

- (IBAction)handleTap:(id)sender {
    [self.view endEditing:true];
}
@end
