//
//  MessagesViewController.m
//  RESideMenuStoryboards
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "MessagesViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface MessagesViewController ()

@property (nonatomic, weak) IBOutlet UITableView *messagesListTable;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messagesListTable.allowsMultipleSelectionDuringEditing = NO;
    [self.messagesListTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MessageListCell"];
    
    // Get list of messages
    [self loadMessagesList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"message_from_login" sender:self];
    }
}

- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void) loadMessagesList {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *buyerQuery = [PFQuery queryWithClassName:@"Chatroom"];
    [buyerQuery whereKey:@"buyer" equalTo:[PFUser currentUser]];
    
    PFQuery *sellerQuery = [PFQuery queryWithClassName:@"Chatroom"];
    [sellerQuery whereKey:@"seller" equalTo:[PFUser currentUser]];
    
    PFQuery *messagesListQuery = [PFQuery orQueryWithSubqueries:@[buyerQuery, sellerQuery]];
    [messagesListQuery orderByDescending:@"createdAt"];
    [messagesListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu chatrooms.", (unsigned long)objects.count);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"MessageListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"row %ld", (long)indexPath.row];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"aww, delete hit");
    }
}

@end
