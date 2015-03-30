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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneBarBtnClick:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"usersFollowCell"];
    
    return cell;
}

@end
