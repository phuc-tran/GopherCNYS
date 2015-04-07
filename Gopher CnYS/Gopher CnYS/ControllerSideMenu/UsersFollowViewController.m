//
//  UsersFollowViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/30/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UsersFollowViewController.h"
#import "UserListingViewController.h"
#import "MBProgressHUD.h"

@interface UsersFollowViewController ()

@property (nonatomic, strong) PFUser *selectedUser;

@end

@implementation UsersFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userFollowTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    if (imageFile != nil) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (!error) {
                if (data != nil) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.avatarImageView.image = image;
                }
            }
        }];
    } else {
        NSString *url = [user objectForKey:@"profileImageURL"];
        [self loadAvatar:url withImage:cell.avatarImageView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedUser = [userFollows objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"userFollow_to_userListing" sender:self];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"userFollow_to_userListing"]) {
        UserListingViewController *destViewController = (UserListingViewController *)[segue destinationViewController];
        destViewController.curUser = self.selectedUser;
    }
}


@end
