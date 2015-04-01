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
#import <Parse/Parse.h>
#import "JSQMessages.h"

@interface UserListingViewController ()

@property (nonatomic, weak) IBOutlet UITableView *productTableView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;

@end

@implementation UserListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.productTableView registerNib:[UINib nibWithNibName:@"UserListingTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductCell"];
    self.productTableView.rowHeight = 140.0f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    cell.productImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"avatarDefault"] withDiameter:70];
    cell.productNameLabel.text = @"Destiny for PS4 used";
    cell.productPriceLabel.text = @"25";
    cell.productDescLabel.text = @"this is the description of Destiny for PS4 Used. this is the description of Destiny for PS4 Used. this is the description of Destiny for PS4 Used";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Event Handling

- (IBAction)feedbackButtonDidTouch:(id)sender {
    NSLog(@"feedbackButton hit");
    [self performSegueWithIdentifier:@"userListing_to_userFeedback" sender:self];
}

- (IBAction)followButtonDidTouch:(id)sender {
    NSLog(@"followButton hit");

}

@end
