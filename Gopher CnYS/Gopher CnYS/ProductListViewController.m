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
#import "ProductDetailViewController.h"
#import "HomeViewController.h"
#import "SellViewController.h"
#import "MyListingViewController.h"
#import "ProductListTableHeaderView.h"
#import "ProductListTableFooterView.h"

@interface ProductListViewController () <ProductTableViewCellDelegate>

@end

NSMutableArray *productData;
NSMutableArray *productMasterData;
//NSArray *productFavoriteData;
PFGeoPoint *currentLocaltion;
NSUInteger selectedIndex;

@implementation ProductListViewController

//@synthesize btnFavorite, btnNew, btnPrice, btnSelectCategory;

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

    productData = [[NSMutableArray alloc] init];
    productMasterData = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil]
               forCellReuseIdentifier:@"ProductTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.pullToRefreshEnabled = NO;
    
    // set the custom view for "pull to refresh". See ProductListTableHeaderView.xib.
//    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductListTableHeaderView" owner:self options:nil];
//    ProductListTableHeaderView *headerView = (ProductListTableHeaderView *)[nib objectAtIndex:0];
//    self.headerView = headerView;
    
    // set the custom view for "load more". See ProductListTableFooterView.xib.
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductListTableFooterView" owner:self options:nil];
    ProductListTableFooterView *footerView = (ProductListTableFooterView *)[nib objectAtIndex:0];
    self.footerView = footerView;
    
    
    //[self loadProductList];
    
    
    [self.productSearchBar setShowsScopeBar:NO];
    [self.productSearchBar sizeToFit];
    // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + self.productSearchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    isFavoriteTopSelected = NO;
    isNewTopSelected = NO;
    isPriceTopSelected = NO;
    
    [self.tableView reloadData];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIImage *buttonImage = [UIImage imageNamed:@"menu-icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [button addTarget:self action:@selector(leftMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)leftMenuClick:(UIBarButtonItem*)btn
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ProductDetaiFormProduct"])
    {
        ProductDetailViewController *vc = [segue destinationViewController];
        [vc setProductData:productData];
        [vc setSelectedIndex:selectedIndex];
        [vc setCurrentLocaltion:currentLocaltion];
    }
    else if ([segue.identifier isEqualToString:@"product_list_form_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }

}

#pragma mark - TableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 162;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ProductDetaiFormProduct" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableViewCell *cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ProductTableViewCell"];
    
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    
    cell.ivProductThumb.image = nil;
    
    cell.lblProductName.text = [[productData objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.lblProductDescription.text = [[[productData objectAtIndex:indexPath.row] objectForKey:@"description"] description];
    NSString *location = [[productData objectAtIndex:indexPath.row] valueForKey:@"locality"];
    if (location == nil) {
        location = [[productData objectAtIndex:indexPath.row] valueForKey:@"adminArea"];
    }
    cell.lblProductMiles.text = location;
    [cell loadData];
    
    if ([self checkIfUserLoggedIn]) {
        cell.btnFavorited.hidden = FALSE;
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
    } else {
        cell.btnFavorited.hidden = TRUE;
    }
    
    NSInteger price  = [[[productData objectAtIndex:indexPath.row] valueForKey:@"price"] integerValue];
    cell.lblProductPrice.text = [NSString stringWithFormat:@"$%ld", (long)price];
    
    //PFGeoPoint *positionItem  = [[productData objectAtIndex:indexPath.row] objectForKey:@"position"];
    //cell.lblProductMiles.text = [NSString stringWithFormat:@"%.f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    
    PFFile *imageFile = [[productData objectAtIndex:indexPath.row] objectForKey:@"photo1"];
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:indexPath.row] objectForKey:@"photo2"];
    }
    
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:indexPath.row] objectForKey:@"photo3"];
    }
    
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:indexPath.row] objectForKey:@"photo4"];
    }
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    PFQuery *query = [PFQuery queryWithClassName:@"Products"];
    [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [query selectKeys:@[@"description", @"title", @"photo1", @"photo2", @"photo3", @"photo4", @"price", @"position", @"createdAt", @"updatedAt", @"favoritors", @"category", @"condition", @"quantity", @"seller", @"country", @"adminArea", @"locality", @"postalCode"]];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    query.skip = [productData count];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            self.canLoadMore = (objects.count > 0);
            NSLog(@"can load more %d", self.canLoadMore);
            if (self.canLoadMore) {
                for (int i = 0; i < objects.count; i++) {
                    [productData addObject:objects[i]];
                }
                NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
                NSArray *tmpArr = [productData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    PFObject *first = (PFObject*)a;
                    PFObject *second = (PFObject*)b;
                    return [self compare:first withProduct:second];
                }];
                productData = [NSMutableArray arrayWithArray:tmpArr];
                NSLog(@"product count %ld", (unsigned long)[productData count]);
                if (_isNewSearch) {
                    [self filterResultsWithSearch];
                }
                [self.tableView reloadData];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)filterResults:(NSString *)searchTerm
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    PFQuery *query = [PFQuery queryWithClassName:@"Products"];
//    [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
//    [query whereKey:@"title" containsString:searchTerm];
//    
//    [query selectKeys:@[@"description", @"title", @"photo1", @"photo2", @"photo3", @"photo4", @"price", @"position", @"createdAt", @"updatedAt", @"favoritors", @"category", @"condition", @"quantity", @"seller", @"country", @"adminArea", @"locality"]];
//    [query orderByDescending:@"createdAt"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        if (!error) {
//            // The find succeeded.
//            productData = objects;
//            NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
//            NSArray *tmpArr = [productData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//                PFObject *first = (PFObject*)a;
//                PFObject *second = (PFObject*)b;
//                return [self compare:first withProduct:second];
//            }];
//            productData = tmpArr;
//            productMasterData = productData;
//            
//            [self.tableView reloadData];
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
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

- (void)filterResultsWithSearch
{
    NSString *name = _searchTab[@"name"];
    NSString *keywords = _searchTab[@"keywords"];
    NSInteger distance = [_searchTab[@"distance"] integerValue];
    BOOL notify = [_searchTab[@"notify"] boolValue];
    NSString *notifystr = ((notify == YES) ? @"YES" : @"NO");
    NSLog(@"name %@ - %@ - %ld miles - Notify me when new post match my search key criteria: %@", name, keywords, (long)distance, notifystr);
    _isNewSearch = NO;
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < productData.count; i++) {
        NSString *title = [[productData objectAtIndex:i] valueForKey:@"title"];
        NSString *desc = [[[productData objectAtIndex:i] objectForKey:@"description"] description];
        PFGeoPoint *positionItem  = [[productData objectAtIndex:i] objectForKey:@"position"];
        double miles = [currentLocaltion distanceInMilesTo:positionItem];
        if ([keywords isEqualToString:@""]) {
            if (miles <= distance) {
                [finalArray addObject:[productData objectAtIndex:i]];
            }
        } else {
            if ([title rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [desc rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound
                || miles <= distance
                )
            {
                [finalArray addObject:[productData objectAtIndex:i]];
            }
        }
    }
    productData = finalArray;
}

-(BOOL) checkIfUserLoggedIn
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action
//-(void)updateSelected:(NSInteger)index {
//    switch (index) {
//        case 0:
//            isFavoriteTopSelected = !isFavoriteTopSelected;
//            isNewTopSelected = NO;
//            isPriceTopSelected = NO;
//            break;
//        case 1:
//            isFavoriteTopSelected = NO;
//            isNewTopSelected = !isNewTopSelected;
//            isPriceTopSelected = NO;
//            break;
//        case 2:
//            isFavoriteTopSelected = NO;
//            isNewTopSelected = NO;
//            isPriceTopSelected = !isPriceTopSelected;
//            break;
//        default:
//            break;
//    }
//    
//    if(isPriceTopSelected) {
//        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter.png"] forState:UIControlStateNormal];
//        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter.png"] forState:UIControlStateHighlighted];
//        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter.png"] forState:UIControlStateSelected];
//    } else {
//        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter1.png"] forState:UIControlStateNormal];
//        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter1.png"] forState:UIControlStateHighlighted];
//        [btnPrice setImage:[UIImage imageNamed:@"ic_price_filter1.png"] forState:UIControlStateSelected];
//    }
//    
//    if(isNewTopSelected) {
//        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter.png"] forState:UIControlStateNormal];
//        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter.png"] forState:UIControlStateHighlighted];
//        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter.png"] forState:UIControlStateSelected];
//    } else {
//        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter1.png"] forState:UIControlStateNormal];
//        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter1.png"] forState:UIControlStateHighlighted];
//        [btnNew setImage:[UIImage imageNamed:@"ic_new_filter1.png"] forState:UIControlStateSelected];
//    }
//    
//    if(isFavoriteTopSelected) {
//        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateNormal];
//        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateHighlighted];
//        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateSelected];
//    } else {
//        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateNormal];
//        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateHighlighted];
//        [btnFavorite setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateSelected];
//    }
//}

//- (IBAction)priceBtnClick:(id)sender
//{
//    //isPriceTopSelected = !isPriceTopSelected;
//    UIButton *btn = (UIButton*)sender;
//    [self updateSelected:btn.tag];
//    
//    if(isPriceTopSelected) {
//        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
//        NSArray *finalArray = [productMasterData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
//        productData = finalArray;
//    } else {
//        productData = productMasterData;
//    }
//    [self.tableView reloadData];
//}
//
//- (IBAction)newBtnClick:(id)sender
//{
//    //isNewTopSelected = !isNewTopSelected;
//    UIButton *btn = (UIButton*)sender;
//    [self updateSelected:btn.tag];
//    
//    if(isNewTopSelected) {
//        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
//        NSArray *finalArray = [productMasterData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
//        productData = finalArray;
//    } else {
//        productData = productMasterData;
//    }
//    [self.tableView reloadData];
//}
//
//- (IBAction)favoriteBtnClick:(id)sender
//{
//    if (![self checkIfUserLoggedIn]) {
//        [self performSegueWithIdentifier:@"product_list_form_login" sender:self];
//    } else {
//        UIButton *btn = (UIButton*)sender;
//        [self updateSelected:btn.tag];
//    
//        if(isFavoriteTopSelected) {
//            NSMutableArray *finalArray = [[NSMutableArray alloc] init];
//            for (int i = 0; i < productMasterData.count; i++) {
//                NSArray *iFavorite = [[productMasterData objectAtIndex:i] objectForKey:@"favoritors"];
//                if ([self checkItemisFavorited:iFavorite]) {
//                    [finalArray addObject:[productMasterData objectAtIndex:i]];
//                }
//            }
//            productData = finalArray;
//            productFavoriteData = productData;
//        } else {
//            productData = productMasterData;
//        }
//    
//        [self.tableView reloadData];
//    }
//}

- (IBAction)gotoSearcg:(UIBarButtonItem *)sender {
    [self.productSearchBar becomeFirstResponder];
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.cameraTabBarItem) {
        MyListingViewController *myListing = (MyListingViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MyListingViewController"];
        myListing.isFromTabBar = YES;
        [[self navigationController] pushViewController:myListing animated:YES];
    } else if (item == self.settingTabBarItem) {
        SearchViewController *searchVC = (SearchViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"mainPageFilter"];
        searchVC.delegate = self;
        [[self navigationController] pushViewController:searchVC animated:YES];
    }
}

#pragma mark - SearchViewControllerDelegate
- (void)onFilterContentForSearch:(NSMutableArray*)favoriteList withPrice:(NSInteger)price withZipCode:(NSString *)zipcode withKeyword:(NSString *)keywords {
    NSLog(@"productMasterData %ld", (unsigned long)productMasterData.count);
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < productMasterData.count; i++) {
        NSInteger ctg = [[[productMasterData objectAtIndex:i] valueForKey:@"category"] integerValue];
        NSInteger p  = [[[productMasterData objectAtIndex:i] valueForKey:@"price"] integerValue];
        NSString *postalCode  = [[productMasterData objectAtIndex:i] valueForKey:@"postalCode"];
        
        NSLog(@"root %ld price %ld", (long)ctg, (long)p);
        if (favoriteList.count <= 0) {
            if (p <= price) {
                NSLog(@"ADD");
                [finalArray addObject:[productMasterData objectAtIndex:i]];
            }
        } else {
            for (int j = 0; j < favoriteList.count; j++) {
                NSInteger index = [[favoriteList objectAtIndex:j] integerValue];
                if (ctg == index && p <= price) {
                    NSLog(@"ADD");
                    [finalArray addObject:[productMasterData objectAtIndex:i]];
                }
            }
        }
    }
    productData = finalArray;
    NSLog(@"productData %ld", (unsigned long)productData.count);
    [self.tableView reloadData];
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

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

#pragma mark - UISearchBarDelegate
// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.productSearchBar resignFirstResponder];
    //[self filterResults:@"Cali"];
}

// called when bookmark button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pull to Refresh

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    ProductListTableHeaderView *hv = (ProductListTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(ProductListTableHeaderView *)self.headerView activityIndicator] stopAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Update the header text while the user is dragging
//
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    ProductListTableHeaderView *hv = (ProductListTableHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// refresh the list. Do your async calls here.
//
- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    
    // Do your async call here
    // This is just a dummy data loader:
    [self performSelector:@selector(addItemsOnTop) withObject:nil afterDelay:2.0];
    // See -addItemsOnTop for more info on how to finish loading
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The method -loadMore was called and will begin fetching data for the next page (more).
// Do custom handling of -footerView if you need to.
//
- (void) willBeginLoadingMore
{
    ProductListTableFooterView *fv = (ProductListTableFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
//
- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    ProductListTableFooterView *fv = (ProductListTableFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:2.0];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dummy data methods

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addItemsOnTop
{
//    for (int i = 0; i < 3; i++)
//        [items insertObject:[self createRandomValue] atIndex:0];
    
    [self.tableView reloadData];
    
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [self refreshCompleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addItemsOnBottom
{
    [self loadProductList];
    [self.tableView reloadData];
    
    // Inform STableViewController that we have finished loading more items
    [self loadMoreCompleted];
}

@end
