//
//  UserListingTableViewCell.m
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UserListingTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UserListingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.curveView.layer.cornerRadius = 5;
    self.curveView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
