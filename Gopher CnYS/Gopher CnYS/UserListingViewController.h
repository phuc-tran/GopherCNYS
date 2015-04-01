//
//  UserListingViewController.h
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "BaseViewController.h"

@interface UserListingViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) PFUser *curUser;
@property (nonatomic, copy) NSArray *products;

@end
