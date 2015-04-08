//
//  MyListingViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/8/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MyListingViewController : BaseViewController


@property (nonatomic, assign) BOOL isFromTabBar;
@property (nonatomic, weak) IBOutlet UITableView *productTableView;
@property (nonatomic, strong) NSArray *products;

@end
