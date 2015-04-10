//
//  CommentTableViewCell.h
//  GopherCNYS
//
//  Created by Vu Tiet on 4/9/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;

@end
