//
//  SearchTabListViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/6/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SearchTabListViewController.h"
#import "SearchTabTableViewCell.h"
#import "MBProgressHUD.h"

@interface SearchTabListViewController () <AddNewSearchViewControllerDelegate>
{
   // NSArray *searchTabList;
}

@end

@implementation SearchTabListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"searchTab_to_login" sender:self];
    }

    // Do any additional setup after loading the view.
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchTabList = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    [self loadSearchTabList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addClick:(UIBarButtonItem *)btn {
    AddNewSearchViewController *addSearchlViewController = [[AddNewSearchViewController alloc] initWithNibName:@"AddNewSearchViewController" bundle:nil];
    addSearchlViewController.delegate = self;
    [self presentPopupViewController:addSearchlViewController animationType:0];

}

#pragma mark - AddNewSearchViewControllerDelegate
- (void)cancelButtonClicked:(AddNewSearchViewController *)aSecondDetailViewController
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (void)addTabButtonClicked:(AddNewSearchViewController*)viewController {
    [self loadSearchTabList];
}


#pragma mark - Helper

- (void)loadSearchTabList{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"SearchTab"];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            NSLog(@"%ld", (unsigned long)objects.count);
            self.searchTabList = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)removeSearchTabList:(NSInteger)index{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFObject *searchTab = self.searchTabList[index];
    [searchTab deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [self loadSearchTabList];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchTabList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTabTableViewCell *cell = (SearchTabTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"searchTabCell"];
    NSString *name = [self.searchTabList[indexPath.row] valueForKey:@"tab_name"];
    NSString *keywords = [self.searchTabList[indexPath.row] valueForKey:@"keywords"];
    NSInteger distance = [[self.searchTabList[indexPath.row] valueForKey:@"distance"] integerValue];
    BOOL notify = [[self.searchTabList[indexPath.row] valueForKey:@"notification"] boolValue];
    NSString *notifystr = ((notify == YES) ? @"YES" : @"NO");
    cell.nameLabel.text = name;
    cell.descriptionLabel.text = [NSString stringWithFormat:@"%@ - %ld miles - Notify me when new post match my search key criteria: %@", keywords, (long)distance, notifystr];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeSearchTabList:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self leftBackClick:nil];
    _searchTab = self.searchTabList[indexPath.row];
    _isNewSearch = YES;
}
@end
