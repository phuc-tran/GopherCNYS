//
//  UserListingTableViewCell.h
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListingTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *curveView;
@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *productDescLabel;
@property (nonatomic, weak) IBOutlet UILabel *productPriceLabel;

@end
