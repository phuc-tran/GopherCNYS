//
//  ProductDetailViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/16/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "PrivateMessageViewController.h"
#import "UserListingViewController.h"
#import "ProductReportViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Social/Social.h>

@interface ProductDetailViewController ()
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@property (nonatomic, strong) NSString *fbProfileURL;
@end

@implementation ProductDetailViewController

@synthesize productData, selectedIndex, currentLocaltion, carousel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Products Detail"];
    
//    NSLog(@"current user objectId -- seller objectId: %@ || %@", [[PFUser currentUser] valueForKey:@"objectId"], [[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] valueForKey:@"objectId"]);
    if (![[[PFUser currentUser] valueForKey:@"objectId"] isEqualToString:[[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] valueForKey:@"objectId"]]) {
        // enable message button if seller and buyer are different people
        self.messageButton.enabled = YES;
    }
    
//    self.carouselController = [[FPCarouselNonXIBViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, carousel.frame.size.height)];
//    [self.carousel addSubview:self.carouselController.view];
    
    PFGeoPoint *positionItem  = [[productData objectAtIndex:selectedIndex] objectForKey:@"position"];
    self.productlocationLbl.text = [NSString stringWithFormat:@"%.f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    
    PFUser *seller = [[productData objectAtIndex:selectedIndex] valueForKey:@"seller"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[seller objectId]];
    [query selectKeys:@[@"username", @"name", @"profileImage", @"profileImageURL", @"fbId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            PFUser *user = [objects objectAtIndex:0];
            NSString *name = [user valueForKey:@"name"];
            if (name == nil) {
                name = user.username;
            }
            self.productSellerLbl.text = name;
            PFFile *imageFile = [user objectForKey:@"profileImage"];
            if (imageFile != nil) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        if (data != nil) {
                            UIImage *image = [UIImage imageWithData:data];
                            self.profileAvatar.image = image;
                        }
                    }
                }];
            } else {
                NSString *url = [user objectForKey:@"profileImageURL"];
                [self loadAvatar:url];
            }
            
//            if ([objects[0] valueForKey:@"fbId"]) {
//                self.fbProfileURL = [NSString stringWithFormat:@"fb://profile/%@", [objects[0] valueForKey:@"fbId"]];
//            }
//            
//            else {
//                // there is no fb id of seller, open fb with news feed
//                self.fbProfileURL = @"fb://feed";
//            }

            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    self.profileAvatar.layer.cornerRadius = 5.0f;
    self.profileAvatar.layer.borderWidth = 2.0f;
    self.profileAvatar.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.profileAvatar.clipsToBounds = YES;
    
    self.productImgaeView.layer.cornerRadius = 5.0f;
    self.productImgaeView.layer.borderWidth = 2.0f;
    self.productImgaeView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImgaeView.clipsToBounds = YES;
    
    PFFile *imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo1"];
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo2"];
    }
    
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo3"];
    }
    
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo4"];
    }
    
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.productImgaeView.image = image;
        }
    }];
}

- (void)loadAvatar:(NSString*)strUrl
{
    NSURL *imageURL = [NSURL URLWithString:strUrl];
    if (imageURL) {
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = self.profileAvatar;
        [self.profileAvatar sd_setImageWithURL:imageURL
                          placeholderImage:nil
                                   options:SDWebImageProgressiveDownload
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      if (!activityIndicator) {
                                          [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                                          activityIndicator.center = weakImageView.center;
                                          [activityIndicator startAnimating];
                                      }
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [activityIndicator removeFromSuperview];
                                     activityIndicator = nil;
                                 }];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    
    self.productNameLbl.text = [[productData objectAtIndex:selectedIndex] valueForKey:@"title"];
    self.productDescription.textColor = [UIColor colorWithRed:148/255.0f green:148/255.0f blue:148/255.0f alpha:1.0f];
    self.productDescription.text = [[[productData objectAtIndex:selectedIndex] objectForKey:@"description"] description];
    NSInteger price  = [[[productData objectAtIndex:selectedIndex] valueForKey:@"price"] integerValue];
    self.productPriceLbl.text = [NSString stringWithFormat:@"$%ld", (long)price];
    bool condition = [[productData objectAtIndex:selectedIndex] valueForKey:@"condition"];
    self.productConditionLbl.text = ((condition == true) ? @"New" : @"Used");
    NSInteger quantity = [[[productData objectAtIndex:selectedIndex] valueForKey:@"quantity"] integerValue];
    self.productQuantityLbl.text = [NSString stringWithFormat:@"%ld", (long)quantity];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [[productData objectAtIndex:selectedIndex] valueForKey:@"createdAt"];
    self.productPostedLbl.text = [dateformater stringFromDate:date];
}

-(CGSize) getContentSize:(UITextView*) myTextView{
    return [myTextView sizeThatFits:CGSizeMake(myTextView.frame.size.width, FLT_MAX)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"productDetail_to_privateMessage"])
    {
        PrivateMessageViewController *vc = (PrivateMessageViewController *)[segue destinationViewController];
        vc.product = [productData objectAtIndex:selectedIndex];
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_userListing"]) {
        UserListingViewController *vc= (UserListingViewController *)[segue destinationViewController];
        vc.curUser = [[productData objectAtIndex:selectedIndex] valueForKey:@"seller"];
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_productReport"]) {
        ProductReportViewController *vc = (ProductReportViewController *)[segue destinationViewController];
        vc.product = [productData objectAtIndex:selectedIndex];
        vc.productImage = self.productImgaeView.image;
        vc.sellerName = self.productSellerLbl.text;
    }
        
}

#pragma mark - Event Handlers

- (IBAction)messageButtonDidTouch:(id)sender {
    // Go to Private Message screen
    [self performSegueWithIdentifier:@"productDetail_to_privateMessage" sender:self];
}

- (IBAction)userListingButtonDidTouch:(id)sender {
    [self performSegueWithIdentifier:@"productDetail_to_userListing" sender:self];
}

- (IBAction)facebookButtonDidTouch:(id)sender {
//    NSURL *url = [NSURL URLWithString:self.fbProfileURL];
//    [[UIApplication sharedApplication] openURL:url];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        // Initialize Compose View Controller
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        // Configure Compose View Controller
        NSString *shareText = [NSString stringWithFormat:@"%@\n%@\n$%@\nGopherCNYS", [[productData objectAtIndex:selectedIndex] valueForKey:@"title"], [[[productData objectAtIndex:selectedIndex] objectForKey:@"description"] description], [[productData objectAtIndex:selectedIndex] valueForKey:@"price"]];
        [vc setInitialText:shareText];
        [vc addImage:self.productImgaeView.image];
        // Present Compose View Controller
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        NSString *message = @"It seems that we cannot talk to Facebook at the moment or you have not yet added your Facebook account to this device. Go to the Settings application to add your Facebook account to this device.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)reportButtonDidTouch:(id)sender {
    // go to product report screen
    [self performSegueWithIdentifier:@"productDetail_to_productReport" sender:self];
     
}

- (IBAction)commentButtonDidTouch:(id)sender {

}


@end
