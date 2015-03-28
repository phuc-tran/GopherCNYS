//
//  MessageTableViewCell.h
//  GopherCNYS
//
//  Created by Vu Tiet on 3/28/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *timeImageView;
@property (nonatomic, weak) IBOutlet UIView *statusView;
@property (nonatomic, assign) BOOL isRead;

@end
