//
//  SearchTabListViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/6/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SearchTabListViewController.h"
#import "SearchTabTableViewCell.h"

@interface SearchTabListViewController () <AddNewSearchViewControllerDelegate>
{
    NSArray *searchTabList;
}

@end

@implementation SearchTabListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
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

#pragma mark - Helper

- (void)loadSearchTabList{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"searchtab.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"searchtab" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:nil];
        NSLog(@"File did not exist! Default copied...");
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    searchTabList = [dict objectForKey:@"search_tab"];
    [self.tableView reloadData];
}

- (void)saveSearchTabList{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"searchtab.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"searchtab" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:nil];
        NSLog(@"File did not exist! Default copied...");
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    searchTabList = [dict objectForKey:@"search_tab"];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchTabList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTabTableViewCell *cell = (SearchTabTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"searchTabCell"];
    NSDictionary *dict = [searchTabList objectAtIndex:indexPath.row];
    NSString *name = dict[@"name"];
    NSString *keywords = dict[@"keywords"];
    NSInteger distance = [dict[@"keywords"] integerValue];
    BOOL notify = [dict[@"notify"] boolValue];
    NSString *notifystr = ((notify == YES) ? @"YES" : @"NO");
    cell.nameLabel.text = name;
    cell.descriptionLabel.text = [NSString stringWithFormat:@"%@ - %ld miles - Notify me when new post match my search key criteria: %@", keywords, (long)distance, notifystr];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}
@end
