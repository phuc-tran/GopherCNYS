//
//  ProductListViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/14/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductTableViewCell.h"


@interface ProductListViewController () <ProductTableViewCellDelegate>

@end

NSArray *productData;
NSArray *productMasterData;
NSMutableArray *distanceProducts;
PFGeoPoint *currentLocaltion;

@implementation ProductListViewController

@synthesize productTableView;
@synthesize btnFavorite, btnNew, btnPrice, btnSignIn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            currentLocaltion = geoPoint;
        }
        NSLog(@"get location %@", currentLocaltion);
    }];

    
    [self.productTableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil]
               forCellReuseIdentifier:@"ProductTableViewCell"];
    
    [self loadProductList];
    categoryData = [NSArray arrayWithObjects:@"All Categories", @"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    
    [self createToolbarItems];
}


-(void)viewWillAppear:(BOOL)animated
{
    //self.navigationController.navigationBar.hidden = YES;
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:68/255.0f green:162/255.0f blue:225/255.0f alpha:1.0f]];
    [self.navigationItem setTitle:@"Products"];
    
    [self.navigationItem setLeftBarButtonItems:nil];
    self.containerPickerView.hidden = YES;
    [self hidePickerViewAnimation];
    
    isFavoriteTopSelected = NO;
    isNewTopSelected = NO;
    isPriceTopSelected = NO;
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
    
    PFGeoPoint *positionItem  = [[productData objectAtIndex:indexPath.row] objectForKey:@"position"];
    cell.lblProductMiles.text = [NSString stringWithFormat:@"%.2f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    
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
     PFQuery *query = [PFQuery queryWithClassName:@"Products"];
    [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [query selectKeys:@[@"description", @"title", @"photo1", @"price", @"position", @"createdAt", @"updatedAt", @"favoritors", @"category"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            productData = objects;
            productMasterData = productData;
            distanceProducts = [[NSMutableArray alloc] init];
            NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *product in productData) {
                PFObject *descriptionObject = [product objectForKey:@"description"];
                NSLog(@"%@", descriptionObject.description);
            }
            
           // productMasterData = [productData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                //return [self compare:[productData objectAtIndex:i] withProduct:[productData objectAtIndex:j]]
           // }];
            
            /*for(NSInteger i=0; i< productData.count - 1; i++) {
                for(NSInteger j=1; j<productData.count; j++) {
                    if([self compare:[productData objectAtIndex:i] withProduct:[productData objectAtIndex:j]])
                    {
                        PFObject *tam= [productData objectAtIndex:i];
                        //[productData objectAtIndex:i] = [productData objectAtIndex:j];
                        //a[j]=tam;
                    }
                }
            }*/
            
            [productTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (int)compare:(PFObject*)product1 withProduct:(PFObject*)product2
{
    PFGeoPoint *point1 = [product1 objectForKey:@"position"];
    PFGeoPoint *point2 = [product2 objectForKey:@"position"];
    
    if(currentLocaltion != nil && point1 != nil && point2 != nil)
    {
        double dist1 = [currentLocaltion distanceInMilesTo:point1];
        double dist2 = [currentLocaltion distanceInMilesTo:point2];
        if(dist1 > dist2)
            return 1;
        else if(dist1 == dist2)
            return 0;
        else
            return -1;
    } else {
        return 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action
-(void)updateSelected:(NSInteger)index {
    switch (index) {
        case 0:
            isFavoriteTopSelected = !isFavoriteTopSelected;
            isNewTopSelected = NO;
            isPriceTopSelected = NO;
            break;
        case 1:
            isFavoriteTopSelected = NO;
            isNewTopSelected = !isNewTopSelected;
            isPriceTopSelected = NO;
            break;
        case 2:
            isFavoriteTopSelected = NO;
            isNewTopSelected = NO;
            isPriceTopSelected = !isPriceTopSelected;
            break;
        default:
            break;
    }
    
    if(isPriceTopSelected) {
        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter.png"] forState:UIControlStateNormal];
        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter.png"] forState:UIControlStateHighlighted];
        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter.png"] forState:UIControlStateSelected];
    } else {
        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter1.png"] forState:UIControlStateNormal];
        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter1.png"] forState:UIControlStateHighlighted];
        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter1.png"] forState:UIControlStateSelected];
    }
    
    if(isNewTopSelected) {
        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter.png"] forState:UIControlStateNormal];
        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter.png"] forState:UIControlStateHighlighted];
        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter.png"] forState:UIControlStateSelected];
    } else {
        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter1.png"] forState:UIControlStateNormal];
        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter1.png"] forState:UIControlStateHighlighted];
        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter1.png"] forState:UIControlStateSelected];
    }
    
    if(isFavoriteTopSelected) {
        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateNormal];
        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateHighlighted];
        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateSelected];
    } else {
        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateNormal];
        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateHighlighted];
        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateSelected];
    }
}
- (IBAction)priceBtnClick:(id)sender
{
    //isPriceTopSelected = !isPriceTopSelected;
    UIButton *btn = (UIButton*)sender;
    [self updateSelected:btn.tag];
    
    if(isPriceTopSelected) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
        NSArray *finalArray = [productData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        productData = finalArray;
    } else {
        productData = productMasterData;
    }
    [productTableView reloadData];
}

- (IBAction)newBtnClick:(id)sender
{
    //isNewTopSelected = !isNewTopSelected;
    UIButton *btn = (UIButton*)sender;
    [self updateSelected:btn.tag];
    
    if(isNewTopSelected) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *finalArray = [productData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        productData = finalArray;
    } else {
        productData = productMasterData;
    }
    [productTableView reloadData];
}

- (IBAction)favoriteBtnClick:(id)sender
{
    //isFavoriteTopSelected = !isFavoriteTopSelected;
    UIButton *btn = (UIButton*)sender;
    [self updateSelected:btn.tag];
    
    if(isFavoriteTopSelected) {
        NSMutableArray *finalArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < productData.count; i++) {
            NSArray *iFavorite = [[productData objectAtIndex:i] objectForKey:@"favoritors"];
            if (iFavorite.count > 0) {
                [finalArray addObject:[productData objectAtIndex:i]];
            }
        }
        productData = finalArray;
    } else {
        productData = productMasterData;
    }
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
    
    if(row == 0) {
        productData = productMasterData;
        [productTableView reloadData];
        return;
    }
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
