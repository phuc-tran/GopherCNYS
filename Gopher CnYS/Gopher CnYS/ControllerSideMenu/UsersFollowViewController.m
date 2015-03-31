//
//  UsersFollowViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/30/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UsersFollowViewController.h"

@interface UsersFollowViewController ()

@end

@implementation UsersFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"follow"];
    
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
    
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"follow"];
    PFUser *userFollow = [userFollows objectAtIndex:sender.tag];
    [relation removeObject:userFollow];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"error %@", error);
    }];
}

@end
