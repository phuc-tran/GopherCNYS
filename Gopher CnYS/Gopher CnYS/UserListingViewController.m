//
//  UserListingViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UserListingViewController.h"
#import "UserListingTableViewCell.h"
#import "MBProgressHUD.h"
#import "UserFeedbackViewController.h"
#import <Parse/Parse.h>
#import "JSQMessages.h"

@interface UserListingViewController ()

@property (nonatomic, weak) IBOutlet UITableView *productTableView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

@end

@implementation UserListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.productTableView registerNib:[UINib nibWithNibName:@"UserListingTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductCell"];
    self.productTableView.rowHeight = 140.0f;
    self.productTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.products = [[NSArray alloc] init];
    
    self.userImageView.layer.cornerRadius = 5.0f;
    self.userImageView.layer.borderWidth = 2.0f;
    self.userImageView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.userImageView.clipsToBounds = YES;
    
    [self loadUserProfile];
    [self loadProducts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
}

-(void)leftBackClick:(UIBarButtonItem*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)loadUserProfile {
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[self.curUser objectId]];
    [query selectKeys:@[@"username", @"name", @"profileImage", @"profileImageURL"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            PFUser *user = [objects objectAtIndex:0];
            NSString *name = [user valueForKey:@"name"];
            if (name == nil) {
                name = user.username;
            }
            self.usernameLabel.text = name;
            PFFile *imageFile = [user objectForKey:@"profileImage"];
            if (imageFile != nil) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        if (data != nil) {
                            UIImage *image = [UIImage imageWithData:data];
                            self.userImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
                        }
                    }
                }];
            } else {
                NSString *url = [user objectForKey:@"profileImageURL"];
                [self loadAvatar:url withImage:self.userImageView];
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)loadProducts {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"Products"];
    [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"seller" equalTo:self.curUser];
    [query selectKeys:@[@"description", @"title", @"photo1", @"price", @"createdAt", @"updatedAt", @"seller"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
            self.products = objects;
            [self.productTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"userListing_to_userFeedback"]) {
        UserFeedbackViewController *destViewController = (UserFeedbackViewController *)[segue destinationViewController];
        destViewController.curUser = self.curUser;
    }
}


#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    PFFile *photo1 = [self.products[indexPath.row] valueForKey:@"photo1"];
    if (photo1) {
        [photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (!error) {
                if (data != nil) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.productImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
                }
            }
        }];
    }
    cell.productNameLabel.text = [self.products[indexPath.row] valueForKey:@"title"];
    cell.productDescLabel.text = [[self.products[indexPath.row] objectForKey:@"description"] description];
    cell.productPriceLabel.text = [NSString stringWithFormat:@"%ld", (long)[[self.products[indexPath.row] valueForKey:@"price"] integerValue]];
//    cell.productImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"avatarDefault"] withDiameter:70];
//    cell.productNameLabel.text = @"Destiny for PS4 used";
//    cell.productPriceLabel.text = @"25";
//    cell.productDescLabel.text = @"this is the description of Destiny for PS4 Used. this is the description of Destiny for PS4 Used. this is the description of Destiny for PS4 Used";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Event Handling

- (IBAction)feedbackButtonDidTouch:(id)sender {
//    NSLog(@"feedbackButton hit");
    [self performSegueWithIdentifier:@"userListing_to_userFeedback" sender:self];
}

- (IBAction)followButtonDidTouch:(id)sender {
    NSLog(@"followButton hit");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"follow"];
    [relation addObject:self.curUser];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
        
        } else {
            NSLog(@"error %@", error);
        }
    }];
    
}

@end
