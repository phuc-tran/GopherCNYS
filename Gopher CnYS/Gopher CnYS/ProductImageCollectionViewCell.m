//
//  ProductImageCollectionViewCell.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/29/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductImageCollectionViewCell.h"

@implementation ProductImageCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    
    self.productImageView.layer.cornerRadius = 5.0f;
    self.productImageView.layer.borderWidth = 2.0f;
    self.productImageView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImageView.clipsToBounds = YES;
}

@end
