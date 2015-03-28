//
//  MessageTableViewCell.m
//  GopherCNYS
//
//  Created by Vu Tiet on 3/28/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsRead:(BOOL)isRead {
    if (isRead == YES) {
        self.statusView.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
    }
    else {
        self.statusView.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:222.0/255.0 blue:172.0/255.0 alpha:1.0];
    }
}

@end
