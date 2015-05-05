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
#import "ProductInformation.h"

@interface ProductListViewController : BaseViewController <UITabBarDelegate, UISearchBarDelegate, UISearchDisplayDelegate, SearchViewControllerDelegate, CLLocationManagerDelegate>
{
    NSArray *categoryData;
    CLLocationManager *locationManager;
    NSString *countryStr;
    NSString *localityStr;
    NSString *adminAreaStr;
    NSString *postalCodeStr;
    NSString *subLocalityStr;
    NSString *subAdminAreaStr;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *filteredProductArray;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITabBarItem *cameraTabBarItem;
@property (weak, nonatomic) IBOutlet UISearchBar *productSearchBar;
@property (nonatomic, assign) BOOL isLoadingOrders;

@property (weak, nonatomic) IBOutlet UITabBar *mainTabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *settingTabBarItem;
- (int)compare:(PFObject*)product1 withProduct:(PFObject*)product2;

@end
