//
//  UsersFollowViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 3/30/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UserFollowTableViewCell.h"
#import "BaseViewController.h"

@interface UsersFollowViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *userFollows;
}
@property (weak, nonatomic) IBOutlet UITableView *userFollowTableView;

@end
