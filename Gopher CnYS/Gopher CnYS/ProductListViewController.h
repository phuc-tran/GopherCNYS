//
//  ProductListViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/14/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "BaseViewController.h"
#import "SBPickerSelector.h"
#import "SearchViewController.h"

@interface ProductListViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, SBPickerSelectorDelegate, UITabBarDelegate, UISearchBarDelegate, UISearchDisplayDelegate, SearchViewControllerDelegate>
{
    NSArray *categoryData;
    BOOL isFavoriteTopSelected;
    BOOL isPriceTopSelected;
    BOOL isNewTopSelected;
    
}
@property (strong,nonatomic) NSMutableArray *filteredProductArray;

@property (weak, nonatomic) IBOutlet UITableView *productTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnNew;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCategory;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITabBarItem *cameraTabBarItem;
@property (weak, nonatomic) IBOutlet UISearchBar *productSearchBar;

@property (weak, nonatomic) IBOutlet UITabBarItem *settingTabBarItem;
- (int)compare:(PFObject*)product1 withProduct:(PFObject*)product2;

@end
