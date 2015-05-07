//
//  SearchTabListViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/6/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AddNewSearchViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import <Parse/Parse.h>

@interface SearchTabListViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *searchTabList;

@end
