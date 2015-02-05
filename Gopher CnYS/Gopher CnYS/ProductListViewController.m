//
//  ProductListViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/14/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductTableViewCell.h"
#import <Parse/Parse.h>

@interface ProductListViewController () <ProductTableViewCellDelegate>

@end

NSArray *productData;
NSArray *productMasterData;

@implementation ProductListViewController

@synthesize productTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.productTableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil]
               forCellReuseIdentifier:@"ProductTableViewCell"];
    
    [self loadProductList];
    categoryData = [NSArray arrayWithObjects:@"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    
    [self createToolbarItems];
}


-(void)viewWillAppear:(BOOL)animated
{
    //self.navigationController.navigationBar.hidden = YES;
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor blueColor]];
    [self.navigationItem setTitle:@"Products"];
    
    [self.navigationItem setLeftBarButtonItems:nil];
    self.containerPickerView.hidden = YES;
    [self hidePickerViewAnimation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 128;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [productData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableViewCell *cell = (ProductTableViewCell *)[productTableView dequeueReusableCellWithIdentifier:@"ProductTableViewCell"];
    
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    
    cell.ivProductThumb.image = nil;
    
    cell.lblProductName.text = [[productData objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.lblProductDescription.text = [[[productData objectAtIndex:indexPath.row] objectForKey:@"description"] description];
    
    NSArray *favoriteArr = [[productData objectAtIndex:indexPath.row] objectForKey:@"favoritors"];
    
    if (favoriteArr.count > 0) { // is favorited
        cell.isFavorited = YES;
        [cell.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateNormal];
        [cell.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateHighlighted];
        [cell.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateSelected];
    } else {
        cell.isFavorited = NO;
        [cell.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateNormal];
        [cell.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateHighlighted];
        [cell.btnFavorited setImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateSelected];
    }
    
    NSInteger price  = [[[productData objectAtIndex:indexPath.row] valueForKey:@"price"] integerValue];
    cell.lblProductPrice.text = [NSString stringWithFormat:@"$%ld", (long)price];
    
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            PFGeoPoint *positionItem  = [[productData objectAtIndex:indexPath.row] objectForKey:@"position"];
            cell.lblProductMiles.text = [NSString stringWithFormat:@"%.2f miles", [geoPoint distanceInMilesTo:positionItem]];
        }
        NSLog(@"PFGeoPoint error %@", error);
    }];
    
    PFFile *imageFile = [[productData objectAtIndex:indexPath.row] objectForKey:@"photo1"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.ivProductThumb.image = image;
        }
    }];
    
    return cell;
}

- (void) loadProductList {
    //ParseRelation<ParseUser> relation = ParseUser.getCurrentUser().getRelation("follow");
    //ParseQuery<ParseUser> query1 = relation.getQuery();
    
//    PFRelation *relation = [[PFUser currentUser] relationForKey:@"follow"];
//    PFQuery *query = [relation query];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//        if (!error) {
//            NSLog(@"OK");
//            productData = results;
//            
//            for (PFObject *object in results) {
//                NSLog(@"%@", object.objectId);
//                // add to your array here
//            }
//        } else {
//            
//        }
//    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Products"];
    [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [query selectKeys:@[@"description", @"title", @"photo1", @"price", @"position", @"createdAt", @"updatedAt", @"favoritors", @"category"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            productData = objects;
            productMasterData = productData;
            NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *product in productData) {
                //NSLog(@"%@", object.objectId);
                PFObject *descriptionObject = [product objectForKey:@"description"];
                
                NSLog(@"%@", descriptionObject.description);
                
            }
            
            [productTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action

- (IBAction)priceBtnClick:(id)sender
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
    NSArray *finalArray = [productData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    
    productData = finalArray;
    [productTableView reloadData];
}

- (IBAction)newBtnClick:(id)sender
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *finalArray = [productData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    
    productData = finalArray;
    [productTableView reloadData];
}

- (IBAction)favoriteBtnClick:(id)sender
{
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < productData.count; i++) {
        NSArray *iFavorite = [[productData objectAtIndex:i] objectForKey:@"favoritors"];
        if (iFavorite.count > 0) {
            [finalArray addObject:[productData objectAtIndex:i]];
        }
    }
    productData = finalArray;
    [productTableView reloadData];
}

- (IBAction)selecetCategoryBtnClick:(id)sender
{
    [self showPickerViewAnimation];
}

#pragma mark - ProductTableViewCellDelegate

- (void)onFavoriteCheck:(NSInteger)index isFavorite:(BOOL)isFv
{
    NSLog(@"index %ld is check %d", (long)index, isFv);
    if(isFv)
    {
        NSMutableArray *array = [[productData objectAtIndex:index] objectForKey:@"favoritors"];
        if(array == nil)
            array = [[NSMutableArray alloc] init];
        [array addObject:[PFUser currentUser].objectId];
        PFObject *item = [productData objectAtIndex:index];
        [item addObject:array forKey:@"favoritors"];
        [item saveInBackground];
        
    } else {
        
        NSMutableArray *array = [[productData objectAtIndex:index] objectForKey:@"favoritors"];
        if(array != nil)
        {
            [array removeObject:[PFUser currentUser].objectId];
            PFObject *item = [productData objectAtIndex:index];
            [item addObject:array forKey:@"favoritors"];
            [item saveInBackground];
        }
    }
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return categoryData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [categoryData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < productMasterData.count; i++) {
        NSInteger ctg = [[[productMasterData objectAtIndex:i] valueForKey:@"category"] integerValue];
        if (ctg == row) {
            [finalArray addObject:[productMasterData objectAtIndex:i]];
        }
    }
    productData = finalArray;
    [productTableView reloadData];
}

- (void)hidePickerViewAnimation{
    //    isHiddenPicker = YES;
    [UIView beginAnimations:@"hidePickerView" context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect frame = self.containerPickerView.frame;
    frame.origin.y += (float)frame.size.height;
    self.containerPickerView.frame = frame;
    [UIView commitAnimations];
}

- (void)showPickerViewAnimation{
    //    isHiddenPicker = NO;
    self.containerPickerView.hidden = NO;
    [UIView beginAnimations:@"showPickerView" context:nil];
    [UIView setAnimationDuration:0.3];
    float heightOfScreen = self.view.frame.size.height;
    float yCoordinate = heightOfScreen - self.containerPickerView.frame.size.height;
    CGRect frame = self.containerPickerView.frame;
    frame.origin.y = yCoordinate;
    self.containerPickerView.frame = frame;
    [UIView commitAnimations];
}

- (void)createToolbarItems
{
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:NULL];
    UIBarButtonItem *doneItem = nil;
    doneItem = [self createDoneButton];
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:spaceItem, doneItem, nil]];
}

- (UIBarButtonItem*)createDoneButton
{
    UIBarButtonItem *doneItem = nil;
    doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:@selector(pickerDoneClick:)];
    return doneItem;
}

- (IBAction)pickerDoneClick:(id)sender {
    [self hidePickerViewAnimation];
}
@end
