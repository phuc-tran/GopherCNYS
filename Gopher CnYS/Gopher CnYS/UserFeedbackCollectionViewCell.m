//
//  UserFeedbackCollectionViewCell.m
//  GopherCNYS
//
//  Created by Vu Tiet on 4/2/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UserFeedbackCollectionViewCell.h"

@implementation UserFeedbackCollectionViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}

@end
