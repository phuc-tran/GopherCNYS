//
//  MessagesViewController.m
//  RESideMenuStoryboards
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "MessagesViewController.h"

@interface MessagesViewController ()

@property (nonatomic, weak) IBOutlet UITableView *messagesListTable;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messagesListTable.allowsMultipleSelectionDuringEditing = NO;
    [self.messagesListTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MessageListCell"];
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
