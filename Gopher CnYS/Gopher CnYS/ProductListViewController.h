//
//  ProductListViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/14/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProductListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *categoryData;
    BOOL isFavoriteTopSelected;
    BOOL isPriceTopSelected;
    BOOL isNewTopSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *productTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIView *containerPickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnNew;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCategory;

- (int)compare:(PFObject*)product1 withProduct:(PFObject*)product2;

@end
