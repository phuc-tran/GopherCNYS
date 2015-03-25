//
//  ProductDetailViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 3/16/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ProductDetailViewController : BaseViewController
{
    NSArray *productData;
    NSUInteger selectedIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *productImgaeView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *productConditionLbl;
@property (weak, nonatomic) IBOutlet UITextView *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *productQuantityLbl;
@property (weak, nonatomic) IBOutlet UILabel *productPostedLbl;

@property (nonatomic, retain) NSArray *productData;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end
