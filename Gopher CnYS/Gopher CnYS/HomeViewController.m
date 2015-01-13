//
//  ViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 12/24/14.
//  Copyright (c) 2014 cnys. All rights reserved.
//

#import "HomeViewController.h"
#import "NextViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

@interface HomeViewController () <GPPSignInDelegate>

@end

@implementation HomeViewController

@synthesize gPlusButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    /*
     Initialize UI
     */
    //[self loadUI];
    
    /*
     Add click event for buttons
     */
    //UITapGestureRecognizer* fbTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(facebookButtonPressed:)];
    //[self.facebookButon setUserInteractionEnabled:YES];
    //[_facebookButon addGestureRecognizer:fbTap];
    
    //UITapGestureRecognizer* gPlusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gPlusButtonPressed:)];
    //[self.gPlusButton setUserInteractionEnabled:YES];
    //[_gPlusButton addGestureRecognizer:gPlusTap];
    
    //UITapGestureRecognizer* signInTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signInButtonPressed:)];
    //[self.gPlusButton setUserInteractionEnabled:YES];
    //[_signinButton addGestureRecognizer:signInTap];
    
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.delegate = self;
    
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
    
    // FB
    //UIImage *imageFB = [UIImage imageNamed:@"fb_normal.png"];
    
    //CGSize fbSize = CGSizeMake(self.view.frame.size.width/4, self.view.frame.size.width/4);
    //UIImage *resizedFB = [self resizeImage:imageFB imageSize:fbSize];
    
    //self.facebookButon = [[UIImageView alloc] initWithImage:resizedFB];
   // self.facebookButon.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.view addSubview:self.facebookButon];
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

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        self.gPlusButton.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
    } else {
        self.gPlusButton.hidden = NO;
        // Perform other actions here
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self loadUI];
    //[self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.hidden = YES;
   // [[GPPSignIn sharedInstance] trySilentAuthentication];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)facebookButtonPressed:(id)sender
{
    NSLog(@"fb login");
    
    NSArray *permissions=[[NSArray alloc] initWithObjects:@"publish_stream",@"publish_actions",@"user_likes",@"user_about_me",nil];
    
    // Ask for publish_actions permissions in context
    
    // Permission hasn't been granted, so ask for publish_actions
    [FBSession openActiveSessionWithPublishPermissions:permissions
                                       defaultAudience:FBSessionDefaultAudienceFriends
                                          allowLoginUI:YES
                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                         if (FBSession.activeSession.isOpen && !error) {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                                                             message:@"Facebook Login Success!!!"
                                                                                            delegate:self
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                         }
                                     }];
}

-(IBAction)gPlusButtonPressed:(id)sender
{
    NSLog(@"gplus");
    
}

-(IBAction)signInButtonPressed:(id)sender
{
    NSLog(@"signin");
}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"buttonSegue"])
//    {
//        NextViewController* vc = segue.destinationViewController;
//        vc.num = @2;
//    }
//}
//
//-(IBAction)longPressed:(UILongPressGestureRecognizer*)sender
//{
//    if(sender.state == UIGestureRecognizerStateBegan)
//        [self performSegueWithIdentifier:@"longSegue" sender:nil];
//}

#pragma mark - GPPSignInDelegate

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
    if (error) {
        NSString *strError = [NSString stringWithFormat:@"Status: Authentication error: %@", error];
        NSLog(@"%@", strError);
        return;
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSString *strError = [NSString stringWithFormat:@"Status: Failed to disconnect: %@", error];
        NSLog(@"%@", strError);
    } else {
        NSLog(@"Status: Disconnected");
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    [[self navigationController] pushViewController:viewController animated:YES];
}

@end
