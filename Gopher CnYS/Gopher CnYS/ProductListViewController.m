//
//  ProductListViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/14/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductTableViewCell.h"
#import "ProductHeaderView.h"


@interface ProductListViewController () <ProductTableViewCellDelegate>

@end

NSArray *productData;
NSArray *productMasterData;
NSArray *productFavoriteData;
NSMutableArray *distanceProducts;
PFGeoPoint *currentLocaltion;

@implementation ProductListViewController

@synthesize productTableView;
@synthesize btnFavorite, btnNew, btnPrice, btnSignIn, btnSelectCategory;

#pragma mark - Self View Life Cycle
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
    categoryData = [NSArray arrayWithObjects:@"All Categories", @"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    
    [self createToolbarItems];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Products"];
    [self setupMenuBarButtonItems];
    
    self.containerPickerView.hidden = YES;
    [self hidePickerViewAnimation];
    
    isFavoriteTopSelected = NO;
    isNewTopSelected = NO;
    isPriceTopSelected = NO;
}

- (void)setupMenuBarButtonItems {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}
- (UIBarButtonItem *)rightMenuBarButtonItem {
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 setFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
    [a1 setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:a1];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIImage *buttonImage = [UIImage imageNamed:@"menu-icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
   return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - TableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    ProductHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ProductHeaderView class]) owner:self options:nil] firstObject];
    
    return headerView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 20.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 162;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ProductDetaiFormProduct" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableViewCell *cell = (ProductTableViewCell *)[productTableView dequeueReusableCellWithIdentifier:@"ProductTableViewCell"];
    
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    
    cell.ivProductThumb.image = nil;
    
    cell.lblProductName.text = [[productData objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.lblProductDescription.text = [[[productData objectAtIndex:indexPath.row] objectForKey:@"description"] description];
    [cell loadData];
    NSArray *favoriteArr = [[productData objectAtIndex:indexPath.row] objectForKey:@"favoritors"];
    
    if ([self checkItemisFavorited:favoriteArr]) { // is favorited
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
    cell.lblProductMiles.text = [NSString stringWithFormat:@"%.f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    
    PFFile *imageFile = [[productData objectAtIndex:indexPath.row] objectForKey:@"photo1"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.ivProductThumb.image = image;
        }
    }];
    
    return cell;
}

- (BOOL)checkItemisFavorited:(NSArray*)array {
    
    NSString *str = [PFUser currentUser].objectId;
    for (NSInteger i = array.count-1; i>-1; i--) {
        NSObject *object = [array objectAtIndex:i];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *item = [NSString stringWithFormat:@"%@", object];
            if ([item rangeOfString:str].location != NSNotFound) {
                return true;
            }
        }
    }
    return false;
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
            distanceProducts = [[NSMutableArray alloc] init];
            NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *product in productData) {
                PFObject *descriptionObject = [product objectForKey:@"description"];
                NSLog(@"%@", descriptionObject.description);
            }
            
            NSArray *tmpArr = [productData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                PFObject *first = (PFObject*)a;
                PFObject *second = (PFObject*)b;
                return [self compare:first withProduct:second];
            }];
            productData = tmpArr;
            productMasterData = productData;
            
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
    self.containerPickerView.hidden = YES;
    [self hidePickerViewAnimation];
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
        NSArray *finalArray = [productMasterData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
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
        NSArray *finalArray = [productMasterData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        productData = finalArray;
    } else {
        productData = productMasterData;
    }
    [productTableView reloadData];
}

- (IBAction)favoriteBtnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [self updateSelected:btn.tag];
    
    if(isFavoriteTopSelected) {
        NSMutableArray *finalArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < productMasterData.count; i++) {
            NSArray *iFavorite = [[productMasterData objectAtIndex:i] objectForKey:@"favoritors"];
            if ([self checkItemisFavorited:iFavorite]) {
                [finalArray addObject:[productMasterData objectAtIndex:i]];
            }
        }
        productData = finalArray;
        productFavoriteData = productData;
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
        item[@"favoritors"] = array;
        [item saveInBackground];
        
    } else {
        
        NSMutableArray *array = [[productData objectAtIndex:index] objectForKey:@"favoritors"];
        if(array != nil)
        {
            NSString *str = [PFUser currentUser].objectId;
            for (NSInteger i=array.count-1; i>-1; i--) {
                NSString *strItem = [array objectAtIndex:i];
                if ([strItem rangeOfString:str].location != NSNotFound) {
                    [array removeObject:strItem];
                }
            }
            
            PFObject *item = [productData objectAtIndex:index];
            [item setObject:array forKey:@"favoritors"];
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
    
    if(isFavoriteTopSelected) {
        if(row == 0) {
            productData = productFavoriteData;
            [productTableView reloadData];
            return;
        } else {
            NSMutableArray *finalArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < productFavoriteData.count; i++) {
                NSInteger ctg = [[[productFavoriteData objectAtIndex:i] valueForKey:@"category"] integerValue];
                if (ctg == row) {
                    [finalArray addObject:[productFavoriteData objectAtIndex:i]];
                }
            }
            productData = finalArray;
        }
    } else {
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
    }
    [btnSelectCategory setTitle:[categoryData objectAtIndex:row] forState:UIControlStateNormal];
    //[categoryData objectAtIndex:row];

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
    float yCoordinate = heightOfScreen - self.containerPickerView.frame.size.height - 66;
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
