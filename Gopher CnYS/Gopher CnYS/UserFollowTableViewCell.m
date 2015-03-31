//
//  UserFollowTableViewCell.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/29/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UserFollowTableViewCell.h"

@implementation UserFollowTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    
    self.avatarImageView.layer.cornerRadius = 5.0f;
    self.avatarImageView.layer.borderWidth = 2.0f;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.avatarImageView.clipsToBounds = YES;
}

@end
