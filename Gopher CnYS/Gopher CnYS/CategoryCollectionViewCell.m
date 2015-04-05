//
//  CategoryCollectionViewCell.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "CategoryCollectionViewCell.h"

@implementation CategoryCollectionViewCell

@synthesize selectedImageView;
@synthesize isSelected;
@synthesize delegate, cellIndex;

- (void)update:(BOOL)selected {
    isSelected = selected;
    if(isSelected) {
        [selectedImageView setImage:[UIImage imageNamed:@"filter_categorysel.png"]];
    } else {
        [selectedImageView setImage:[UIImage imageNamed:@"filter_category.png"]];
    }
}

- (IBAction)selected:(id)sender
{
    if(delegate != nil)
        [delegate onCellSelect:cellIndex];
}
@end
