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
#import "CommentViewController.h"
#import "HomeViewController.h"
#import "ILTranslucentView.h"
#import <Social/Social.h>
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

@interface ProductDetailViewController ()
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@property (nonatomic, strong) NSString *fbProfileURL;
@property (nonatomic, strong) CommentViewController *commentViewController;
@property (nonatomic, strong) ILTranslucentView *translucentView;

@end

@implementation ProductDetailViewController

@synthesize productData, selectedIndex, currentLocaltion, carouselProduct, productPage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![[[PFUser currentUser] valueForKey:@"objectId"] isEqualToString:[[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] valueForKey:@"objectId"]]) {
        // enable message button if seller and buyer are different people
        self.messageButton.enabled = YES;
    }
    carouselProduct.pagingEnabled = true;
    carouselProduct.type = iCarouselTypeRotary;
    
        
    PFGeoPoint *positionItem  = [[productData objectAtIndex:selectedIndex] objectForKey:@"position"];
    self.productlocationLbl.text = [NSString stringWithFormat:@"%.f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    productImageList = [[NSMutableArray alloc] init];
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
                [self loadAvatar:url withImage:self.profileAvatar];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    self.profileAvatar.layer.cornerRadius = 5.0f;
    self.profileAvatar.layer.borderWidth = 2.0f;
    self.profileAvatar.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.profileAvatar.clipsToBounds = YES;
    

    NSArray *imageList = @[@"photo1", @"photo2", @"photo3", @"photo4"];
    for (int i = 0; i < imageList.count; i++) {
        PFFile *imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:imageList[i]];
        if (imageFile != nil) {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [productImageList addObject:image];
                    productPage.numberOfPages = productImageList.count;
                    productPage.currentPage = 0;
                    [carouselProduct reloadData];
                }
            }];
        }
    }
   
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"chat_icon.png"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"Everyone can view these comments. Use "];
    [myString appendAttributedString:attachmentString];
    [myString appendAttributedString:[[NSAttributedString alloc] initWithString:@" for the personal information."]];
    self.viewCommentDescLabel.attributedText = myString;
}

-(void)viewWillAppear:(BOOL)animated {
    
   [super setupLeftBackBarButtonItem];
    
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

- (IBAction)leftBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        vc.incomingSenderID = [[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] objectId];
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_userListing"]) {
        UserListingViewController *vc= (UserListingViewController *)[segue destinationViewController];
        vc.curUser = [[productData objectAtIndex:selectedIndex] valueForKey:@"seller"];
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_productReport"]) {
        ProductReportViewController *vc = (ProductReportViewController *)[segue destinationViewController];
        vc.product = [productData objectAtIndex:selectedIndex];
        vc.productImage = productImageList[0];
        vc.sellerName = self.productSellerLbl.text;
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_comment"]) {
        CommentViewController *vc = (CommentViewController *)[segue destinationViewController];
//        vc.userInfoImage = [self takeSnapshotOfUserInfo];
        vc.productId = [[productData objectAtIndex:selectedIndex] objectId];
        vc.sellerId = [[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] objectId];
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_login"]) {
        HomeViewController *vc = (HomeViewController *)[segue destinationViewController];
        vc.shouldGoBack = YES;
    }
        
}

- (UIImage *)takeSnapshotOfUserInfo {
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
//    
//    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    // Crop image
//    CGRect cropRect=CGRectMake(0, 20, self.view.bounds.size.width, 104);
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
//    UIImage *cropedImage=[UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    
//    return image;
    
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    return screenshot;
}

- (CommentViewController *)commentViewController {
    if (!_commentViewController) {
        _commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
        _commentViewController.view.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-100);
        _commentViewController.delegate = self;
        
//        _commentViewController.userInfoImage = [self takeSnapshotOfUserInfo];
        _commentViewController.productId = [[productData objectAtIndex:selectedIndex] objectId];
        _commentViewController.sellerId = [[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] objectId];

    }
    
    return _commentViewController;
}

- (ILTranslucentView *)translucentView {
    if (!_translucentView) {
         _translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100)];
        _translucentView.backgroundColor = [UIColor clearColor];
        _translucentView.translucentTintColor = [UIColor clearColor];
        _translucentView.alpha = 0.0f;
        _translucentView.translucentStyle = UIBarStyleDefault;
        _translucentView.tag = 2512;
    }
    return _translucentView;
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
        NSString *shareText = [NSString stringWithFormat:@"%@\n%@\n$%@\n", [[productData objectAtIndex:selectedIndex] valueForKey:@"title"], [[[productData objectAtIndex:selectedIndex] objectForKey:@"description"] description], [[productData objectAtIndex:selectedIndex] valueForKey:@"price"]];
        [vc setInitialText:shareText];
        [vc addURL:[NSURL URLWithString:@"https://fb.me/1029164840445781"]];
        [vc addImage:productImageList[0]];
        // Present Compose View Controller
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        NSString *message = @"It seems that we cannot talk to Facebook at the moment or you have not yet added your Facebook account to this device. Go to the Settings application to add your Facebook account to this device.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)reportButtonDidTouch:(id)sender {
  
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"productDetail_to_login" sender:self];
    } else {
        // go to product report screen
        [self performSegueWithIdentifier:@"productDetail_to_productReport" sender:self];
    }
    
}

- (IBAction)commentButtonDidTouch:(id)sender {
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"productDetail_to_login" sender:self];
    } else {
//        [self performSegueWithIdentifier:@"productDetail_to_comment" sender:self];

        CGRect frame = self.commentViewController.view.frame;
        frame.origin.y = CGRectGetHeight(self.view.frame);
        self.commentViewController.view.frame = frame;
        [self.view addSubview:self.commentViewController.view];
        
        // Add translution view
        UIWindow *curWindow = [[UIApplication sharedApplication] keyWindow];
        [curWindow addSubview:self.translucentView];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect showFrame = self.commentViewController.view.frame;
            showFrame.origin.y = 100;
            self.commentViewController.view.frame = showFrame;
            self.translucentView.alpha = 1.0f;
        } completion:^(BOOL finished){
        }];
        
    }
    
}

#pragma mark - CommentViewControllerDelegate

- (void)hideComment {
//    UIView *translucentView = [self.view viewWithTag:2512];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.commentViewController.view.frame;
        frame.origin.y = self.view.frame.size.height;
        self.commentViewController.view.frame = frame;
        self.translucentView.alpha = 0;
    } completion:^(BOOL finished){
        
        // Remove views belong to comments
        [self.commentViewController.view removeFromSuperview];
        [self.translucentView removeFromSuperview];
    }];
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return productImageList.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 220.0f, 180.0f)];
        ((UIImageView *)view).image = productImageList[index];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.backgroundColor = [UIColor clearColor];
        [view.layer setMasksToBounds:YES];
        [view.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [view.layer setBorderWidth: 3.0];
    }
    else
    {
        //get a reference to the label in the recycled view
    }
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value;
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.114729;
        
    } else if (option == iCarouselOptionWrap) {
        
        return 1.0;
        
    } else if (option == iCarouselOptionArc) {
        
        return 2 * M_PI * 0.5f;
        
    } else if (option == iCarouselOptionRadius) {
        
        return value * 0.8f;
        
    }
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    productPage.currentPage = carousel.currentItemIndex;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    UIImage *selectedImage = productImageList[index];
    
    imageInfo.image = selectedImage;
    imageInfo.referenceRect = carouselProduct.frame;
    imageInfo.referenceView = carouselProduct.superview;
    imageInfo.referenceContentMode = carouselProduct.contentMode;
    imageInfo.referenceCornerRadius = carouselProduct.layer.cornerRadius;
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}
@end
