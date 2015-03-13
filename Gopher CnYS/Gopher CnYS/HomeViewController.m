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
    
    if ([self checkIfUserLoggedIn])
    {
        NSLog(@"User has logged in with FB. Let's load data");
        [self openProductList];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    NSLog(@"viewLoginHeightConstraint %f", self.viewLoginTopConstraint.constant);
    //self.viewLoginTopConstraint.constant = 100;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:@"UIKeyboardWillShowNotification"];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:@"UIKeyboardDidHideNotification"];
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

-(BOOL) checkIfUserLoggedIn
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        return YES;
    }
    return NO;
}

-(void) openProductList
{
    [self performSegueWithIdentifier:@"product_list_from_home" sender:self];
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
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
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
    }
}


-(IBAction)signIn:(id)sender
{
    NSString *userName = _txtUserName.text;
    NSString *password = _txtPassword.text;
    
    if (userName.length <= 0) {
        return;
    } else if (password.length <= 0) {
        return;
    }
    
    [PFUser logInWithUsernameInBackground:userName password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            NSLog(@"Login OK");
                                            [self openProductList];
                                        } else {
                                            NSLog(@"Failed");
                                        }
                                    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard Handler
- (void) keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"Keyboard Height: %f Width: %f", kbSize.height, kbSize.width);
    NSLog(@"yyyy %f", self.viewLogin.frame.origin.y);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewLoginTopConstraint.constant = 100;
    }];
}

- (void) keyboardDidHide:(NSNotification *)note {
    
    // move the view back to the origin
    CGRect frame = self.viewLogin.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewLoginTopConstraint.constant = 273;
    }];
}
@end
