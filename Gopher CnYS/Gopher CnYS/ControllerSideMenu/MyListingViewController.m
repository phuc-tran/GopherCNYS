//
//  MyListingViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/8/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "MyListingViewController.h"
#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "UserListingTableViewCell.h"
#import "JSQMessages.h"
#import "ProductDetailViewController.h"
#import "ProductInformation.h"
#import "SellViewController.h"

@interface MyListingViewController ()

@property (nonatomic, assign) NSInteger seletectedIndex;
@property (nonatomic, strong) PFGeoPoint *currentLocaltion;

@end

@implementation MyListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.currentLocaltion = geoPoint;
        }
    }];

    [self.productTableView registerNib:[UINib nibWithNibName:@"UserListingTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductCell"];
    self.productTableView.rowHeight = 140.0f;
    self.productTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    self.products = [[NSArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"add_product_from_login" sender:self];
    } else {
        [self loadProducts];
    }
}

- (IBAction)leftBackClick:(id)sender {
    if (self.isFromTabBar) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [super leftBackClick:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"add_product_from_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }
    else if ([[segue identifier] isEqualToString:@"mylisting_to_productdetail"])
    {
        ProductDetailViewController *vc = [segue destinationViewController];
        [vc setProductData:self.products];
        [vc setSelectedIndex:self.seletectedIndex];
        [vc setCurrentLocaltion:self.currentLocaltion];
    }
    else if ([[segue identifier] isEqualToString:@"addProductViewController"])
    {
        SellViewController *sellVC = [segue destinationViewController];
        [sellVC setProductInfo:self.products[self.seletectedIndex]];
    }

}


- (void)loadProducts {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [ProductInformation query];
    [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"seller" equalTo:[PFUser currentUser]];
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

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    PFFile *imageFile = [[self.products objectAtIndex:indexPath.row] objectForKey:@"photo1"];
    if (imageFile == nil) {
        imageFile = [[self.products objectAtIndex:indexPath.row] objectForKey:@"photo2"];
    }
    
    if (imageFile == nil) {
        imageFile = [[self.products objectAtIndex:indexPath.row] objectForKey:@"photo3"];
    }
    
    if (imageFile == nil) {
        imageFile = [[self.products objectAtIndex:indexPath.row] objectForKey:@"photo4"];
    }
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.seletectedIndex = indexPath.row;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Product" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit product", @"View detail", nil];
    [actionSheet showInView:self.view];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ProductInformation *item = self.products[indexPath.row];
        item[@"deleted"] = [NSNumber numberWithBool:YES];
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"error %@", error);
            [self loadProducts];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UIActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button at index: %ld clicked\nIts title is '%@'", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    switch (buttonIndex) {
        case 0: // Edit product
            [self performSegueWithIdentifier:@"addProductViewController" sender:self];
            break;
        case 1: //View Detail
            [self performSegueWithIdentifier:@"mylisting_to_productdetail" sender:self];
            break;
        default:
            break;
    }
}
@end
