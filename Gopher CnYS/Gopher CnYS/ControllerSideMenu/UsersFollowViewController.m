//
//  UsersFollowViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/30/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UsersFollowViewController.h"
#import "MBProgressHUD.h"

@interface UsersFollowViewController ()

@end

@implementation UsersFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadUserFollow];
}

- (void)loadUserFollow {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"follow"];
    
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            // There was an error
            
        } else {
            userFollows = objects;
            
            [self.userFollowTableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneBarBtnClick:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userFollows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserFollowTableViewCell *cell = (UserFollowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"usersFollowCell"];
    
    PFUser *user = [userFollows objectAtIndex:indexPath.row];
    NSString *name = [user objectForKey:@"name"];
    if (name == nil) {
        name = user.username;
    }
    cell.nameLabel.text = name;
    cell.btnUnFollow.tag = indexPath.row;
    PFFile *imageFile = [user objectForKey:@"profileImage"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            if (data != nil) {
                UIImage *image = [UIImage imageWithData:data];
                cell.avatarImageView.image = image;
            }
        }
    }];
    
    return cell;
}

- (IBAction)unFollowbtnClick:(UIButton *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"follow"];
    PFUser *userFollow = [userFollows objectAtIndex:sender.tag];
    [relation removeObject:userFollow];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [self loadUserFollow];
            [self.userFollowTableView reloadData];
        } else {
            NSLog(@"error %@", error);
        }
    }];
}

@end
