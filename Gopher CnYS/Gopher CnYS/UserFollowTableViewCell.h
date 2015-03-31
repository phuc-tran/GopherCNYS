//
//  UserFollowTableViewCell.h
//  GopherCNYS
//
//  Created by Minh Tri on 3/29/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserFollowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnUnFollow;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
