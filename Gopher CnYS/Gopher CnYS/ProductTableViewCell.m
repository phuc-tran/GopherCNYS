//
//  ProductTableViewCell.m
//  GopherCNYS
//
//  Created by Trần Huy Phúc on 1/24/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductTableViewCell.h"

@implementation ProductTableViewCell

@synthesize btnFavorited;
@synthesize cellIndex;
@synthesize delegate;
@synthesize isFavorited;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
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
