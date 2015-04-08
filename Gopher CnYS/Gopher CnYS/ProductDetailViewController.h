//
//  ProductDetailViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 3/16/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Parse/Parse.h>
#import "FPCarouselNonXIBViewController.h"

@interface ProductDetailViewController : BaseViewController
{
    NSArray *productData;
    NSUInteger selectedIndex;
    PFGeoPoint *currentLocaltion;
}

@property (weak, nonatomic) IBOutlet UIImageView *productImgaeView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *productConditionLbl;
@property (weak, nonatomic) IBOutlet UITextView *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *productQuantityLbl;
@property (weak, nonatomic) IBOutlet UILabel *productPostedLbl;
@property (weak, nonatomic) IBOutlet UILabel *productlocationLbl;
@property (weak, nonatomic) IBOutlet UILabel *productSellerLbl;
@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;
@property (weak, nonatomic) IBOutlet UILabel *viewCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCommentDescLabel;

@property (nonatomic, retain) NSArray *productData;
@property (nonatomic, retain) NSArray *product;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, retain) PFGeoPoint *currentLocaltion;

@property (nonatomic, strong) IBOutlet UIView *carousel;
@property (strong,nonatomic) FPCarouselNonXIBViewController *carouselController;

@end
