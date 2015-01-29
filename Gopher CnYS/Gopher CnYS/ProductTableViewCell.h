//
//  ProductTableViewCell.h
//  GopherCNYS
//
//  Created by Trần Huy Phúc on 1/24/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewCell : UITableViewCell
{
    BOOL isFavorited;
}

@property (nonatomic, weak) IBOutlet UIImageView *ivProductThumb;
@property (nonatomic, weak) IBOutlet UILabel *lblProductName;
@property (nonatomic, weak) IBOutlet UILabel *lblProductDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblProductPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblProductMiles;
@property (nonatomic, weak) IBOutlet UIButton *btnFavorited;

@end
