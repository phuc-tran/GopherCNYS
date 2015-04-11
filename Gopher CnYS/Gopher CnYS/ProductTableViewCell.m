//
//  ProductTableViewCell.m
//  GopherCNYS
//
//  Created by Trần Huy Phúc on 1/24/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductTableViewCell.h"

@implementation ProductTableViewCell
@synthesize productView;
@synthesize ivProductThumb;
@synthesize btnFavorited;
@synthesize cellIndex;
@synthesize delegate;
@synthesize isFavorited;
@synthesize lblProductPrice;

- (void)awakeFromNib {
    // Initialization code
}

- (void)loadData
{
    [ivProductThumb.layer setMasksToBounds:YES];
    [ivProductThumb.layer setCornerRadius:5.0];
    [productView setBackgroundColor:[UIColor whiteColor]];
    [productView.layer setMasksToBounds:YES];
    [productView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [productView.layer setBorderWidth: 1.0];
    [productView.layer setCornerRadius:8.0];
    productView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    productView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    productView.layer.shadowOpacity = 0.6f;
}
#pragma mark - Action

- (IBAction)favoriteItemBtnClick:(id)sender
{
    
    isFavorited = !isFavorited;
    if(delegate) {
        [delegate onFavoriteCheck:cellIndex isFavorite:isFavorited];
    }
    
    if (isFavorited) {
        [btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateNormal];
        [btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateHighlighted];
        [btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateSelected];
    } else {
        [btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateNormal];
        [btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateHighlighted];
        [btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateSelected];
    }
}
@end
