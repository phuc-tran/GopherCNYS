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

- (void)loadData:(ProductInformation*)product
{
    self.ivProductThumb.image = nil;
    
    self.lblProductName.text = product.title ;
    self.lblProductDescription.text = [[product objectForKey:@"description"] description];

    NSString *location = product.locality;
    if (location == nil) {
        location = product.adminArea;
    }
    self.lblProductMiles.text = location;
    
    if ([self checkIfUserLoggedIn]) {
        self.btnFavorited.hidden = FALSE;
        NSArray *favoriteArr = product.favoritors;
        
        if ([self checkItemisFavorited:favoriteArr]) { // is favorited
            self.isFavorited = YES;
            [self.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateNormal];
            [self.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateHighlighted];
            [self.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateSelected];
        } else {
            self.isFavorited = NO;
            [self.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateNormal];
            [self.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateHighlighted];
            [self.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateSelected];
        }
    } else {
        self.btnFavorited.hidden = TRUE;
    }
    
    NSInteger price  = [product.price integerValue];
    self.lblProductPrice.text = [NSString stringWithFormat:@"%ld", (long)price];
    
    PFFile *imageFile = product.photo1;
    if (imageFile == nil) {
        imageFile = product.photo2;
    }
    
    if (imageFile == nil) {
        imageFile = product.photo3;
    }
    
    if (imageFile == nil) {
        imageFile = product.photo4;
    }
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.ivProductThumb.image = image;
        }
    }];
}

-(BOOL) checkIfUserLoggedIn
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        return YES;
    }
    return NO;
}

- (BOOL)checkItemisFavorited:(NSArray*)array {
    
    NSString *str = [PFUser currentUser].objectId;
    for (NSInteger i = array.count-1; i>-1; i--) {
        NSObject *object = [array objectAtIndex:i];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *item = [NSString stringWithFormat:@"%@", object];
            if ([item rangeOfString:str].location != NSNotFound) {
                return true;
            }
        }
    }
    return false;
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
