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
#import "SVPullToRefresh.h"
#import "CLPlacemark+ShortState.h"

@interface ProductListViewController () <ProductTableViewCellDelegate>
{
    CGPoint pointNow;
    NSMutableArray *productData;
    PFGeoPoint *currentLocaltion;
    NSUInteger selectedIndex;
    PFQuery *queryTotal;
    BOOL isSearchNavi;
    BOOL isLoadFinished;
    BOOL isSearchMainPage;
    
    UILabel *noDataLable;
    BOOL isShowNoData;
    NSInteger rangeIndex;
}
@end


@implementation ProductListViewController

@synthesize isLoadingOrders;

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
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [locationManager startUpdatingLocation];

    productData = [[NSMutableArray alloc] init];
    
    noDataLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.tableView.frame.size.width, 40)];
    noDataLable.text = @"No listings are available for this zip code";
    noDataLable.textColor = [UIColor darkGrayColor];
    noDataLable.textAlignment = NSTextAlignmentCenter;
    noDataLable.hidden = YES;
    isShowNoData = NO;
    [self.tableView addSubview:noDataLable];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductTableViewCell"];

//    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //self.pullToRefreshEnabled = NO;
    //[self.productSearchBar setShowsScopeBar:NO];
    //[self.productSearchBar sizeToFit];
    // Hide the search bar until user scrolls up
    //CGRect newBounds = [[self tableView] bounds];
    //newBounds.origin.y = newBounds.origin.y + self.productSearchBar.bounds.size.height;
    //[[self tableView] setBounds:newBounds];
    
    //init query
    queryTotal = [ProductInformation query];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    queryTotal.limit = 100;
    
    
    isSearchNavi = NO;
    isLoadFinished = YES;
    isSearchMainPage = NO;
    
    // setup pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self loadProductList];
    }];
    
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadProductList];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = nil;
    [self.mainTabBar setSelectedItem:nil];
    
    // Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBacklink:) name:@"GopherReceivePushBacklink" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isNewSearch) {
        [locationManager startUpdatingLocation];
        [self filterResultsWithSearch];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isNewSearch = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GopherReceivePushBacklink" object:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
        NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    
    // stop updating location in order to save battery power
    [locationManager stopUpdatingLocation];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             
             // strAdd -> take bydefault value nil
             NSString *strAdd = nil;
             
             if ([placemark.subThoroughfare length] != 0) {
                 strAdd = placemark.subThoroughfare;
                 NSLog(@"subThoroughfare %@", strAdd);
             }
             
             if ([placemark.thoroughfare length] != 0) {
                 strAdd = placemark.thoroughfare;
                 NSLog(@"thoroughfare %@", strAdd);
             }
             
             if ([placemark.postalCode length] != 0) {
                 strAdd = placemark.postalCode;
                 postalCodeStr = strAdd;
                 NSLog(@"postalCodeStr %@", postalCodeStr);
             }
             
             if ([placemark.locality length] != 0) {
                 strAdd = placemark.locality;
                 localityStr = strAdd;
                 NSLog(@"localityStr %@", localityStr);
             }
             
             if ([placemark.country length] != 0) {
                 strAdd = placemark.country;
                 countryStr = strAdd;
                 NSLog(@"countryStr %@", countryStr);
             }
             
             if ([placemark.administrativeArea length] != 0) {
                 strAdd = placemark.shortState;
                 adminAreaStr = strAdd;
                 NSLog(@"adminAreaStr %@", adminAreaStr);
             }
             
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             if ([defaults objectForKey:@"product_range"] != nil) {
                 rangeIndex = [[defaults objectForKey:@"product_range"] integerValue];
             } else {
                 rangeIndex = 3;
             }
             
             if(rangeIndex >= 0) {
                 switch (rangeIndex) {
                     case 0: // Town
                         if (localityStr != nil) {
                             [queryTotal whereKey:@"locality" equalTo:localityStr];
                         }
                         break;
                     case 1: // City
                         break;
                     case 2: // State
                         if (adminAreaStr != nil) {
                             [queryTotal whereKey:@"adminArea" equalTo:adminAreaStr];
                         }
                         break;
                     case 3: // Country
                         if (countryStr != nil) {
                             [queryTotal whereKey:@"country" equalTo:countryStr];
                         }
                         break;
                     case 4: // World
                         break;
                     default:
                         break;
                 }
             }
             
            [self.tableView triggerPullToRefresh];
         }
         
     }];
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
    ProductInformation *product = [productData objectAtIndex:indexPath.row];
    [cell loadData:product];
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
    if (queryTotal != nil) {
        NSLog(@"load product list");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        isLoadFinished = NO;
        [queryTotal orderByDescending:@"createdAt"];
        queryTotal.skip = [productData count];
        NSLog(@"query %ld", (long)queryTotal.skip);
        [queryTotal findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView.pullToRefreshView stopAnimating];
            if (!error) {
                // The find succeeded.
                isLoadFinished = YES;
                NSInteger distance = 30;
                if(_isNewSearch) {
                    distance = [[_searchTab valueForKey:@"distance"] integerValue];
                }
                
                for (ProductInformation *object in objects) {
                    if (rangeIndex == 1 || _isNewSearch) // City <= 30 miles
                    {
                        PFGeoPoint *point = [object objectForKey:@"position"];
                        if(currentLocaltion != nil && point != nil)
                        {
                            double dist = [currentLocaltion distanceInMilesTo:point];
                            NSLog(@"dist %f", dist);
                            if(dist <= distance) {
                                [productData addObject:object];
                            }
                        }
                    } else {
                        [productData addObject:object];
                    }
                }
                
                NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
                NSLog(@"product count %ld", (unsigned long)[productData count]);
                if (isShowNoData) {
                    if (productData.count <= 0) {
                        noDataLable.hidden = NO;
                    } else {
                        noDataLable.hidden = YES;
                    }
                } else {
                    noDataLable.hidden = YES;
                }
                
                [self.tableView reloadData];
//                if (isSearchNavi) {
//                    [self.searchDisplayController.searchResultsTableView reloadData];
//                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            isLoadingOrders = NO;
        }];
    }
}

- (void)filterResults:(NSString *)searchTerm
{
    [productData removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *queryTitle = [ProductInformation query];
    [queryTitle whereKey:@"title" matchesRegex:searchTerm modifiers:@"i"];
    
    PFQuery *queryDes = [ProductInformation query];
    [queryDes whereKey:@"description" matchesRegex:searchTerm modifiers:@"i"];
    
    queryTotal = [PFQuery orQueryWithSubqueries:@[queryTitle, queryDes]];
    [queryTotal orderByDescending:@"createdAt"];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    //queryTotal.limit = 100;
    
    [queryTotal findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
                NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
                for (ProductInformation *object in objects) {
                    if (rangeIndex == 1) // City <= 30 miles
                    {
                        PFGeoPoint *point = [object objectForKey:@"position"];
                        if(currentLocaltion != nil && point != nil)
                        {
                            double dist = [currentLocaltion distanceInMilesTo:point];
                            NSLog(@"dist %f", dist);
                            if(dist <= 30) {
                                [productData addObject:object];
                            }
                        }
                    } else {
                        [productData addObject:object];
                    }
                }
                NSLog(@"product count %ld", (unsigned long)[productData count]);
            //}
            [self.searchDisplayController.searchResultsTableView reloadData];
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

- (void)filterResultsWithSearch
{
    NSString *name = [_searchTab valueForKey:@"tab_name"];
    NSString *keywords = [_searchTab valueForKey:@"keywords"];
     NSInteger distance = [[_searchTab valueForKey:@"distance"] integerValue];
    BOOL notify = [[_searchTab valueForKey:@"notification"] boolValue];
    NSString *notifystr = ((notify == YES) ? @"YES" : @"NO");
    NSLog(@"name %@ - %@ - %ld miles - Notify me when new post match my search key criteria: %@", name, keywords, (long)distance, notifystr);
    //_isNewSearch = NO;
    
    [productData removeAllObjects];
    PFQuery *queryTitle = [ProductInformation query];
    [queryTitle whereKey:@"title" matchesRegex:keywords modifiers:@"i"];
    
    PFQuery *queryDes = [ProductInformation query];
    [queryDes whereKey:@"description" matchesRegex:keywords modifiers:@"i"];
    
    queryTotal = [PFQuery orQueryWithSubqueries:@[queryTitle, queryDes]];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    queryTotal.limit = 100;
    
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
- (IBAction)gotoSearcg:(UIBarButtonItem *)sender {
    if (isLoadFinished) {
        [self.productSearchBar becomeFirstResponder];
    }
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if (isLoadFinished == NO) {
        return;
    }
    if (item == self.cameraTabBarItem) {
        SellViewController *sellVC = (SellViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"sellViewController"];
        [[self navigationController] pushViewController:sellVC animated:YES];
        
    } else if (item == self.settingTabBarItem) {
        SearchViewController *searchVC = (SearchViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"mainPageFilter"];
        searchVC.delegate = self;
        [[self navigationController] pushViewController:searchVC animated:YES];
    }
}

#pragma mark - SearchViewControllerDelegate
- (void)onFilterContentForSearch:(NSMutableArray*)categoryList withPrice:(NSInteger)price withZipCode:(NSString *)zipcode withKeyword:(NSString *)keywords favoriteSelected:(BOOL)isSelected conditionOption:(NSInteger)condition rangeOption:(NSInteger)rangindex {
    [productData removeAllObjects];
    NSLog(@"aaaa %ld", (unsigned long)productData.count);
    isShowNoData = NO;
    if (keywords != nil && keywords.length > 0 && [keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ) {
        PFQuery *queryTitle = [ProductInformation query];
        [queryTitle whereKey:@"title" matchesRegex:keywords modifiers:@"i"];
        
        PFQuery *queryDes = [ProductInformation query];
        [queryDes whereKey:@"description" matchesRegex:keywords modifiers:@"i"];
        
        queryTotal = [PFQuery orQueryWithSubqueries:@[queryTitle, queryDes]];
    } else {
        queryTotal = [ProductInformation query];
    }
        
    
    if (price > 0) {
        [queryTotal whereKey:@"price" lessThanOrEqualTo:[NSNumber numberWithInteger:price]];
    }
    if (zipcode != nil && zipcode.length > 0 && [zipcode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ) {
        if (![zipcode isEqualToString:@"85345"]) {
            [queryTotal whereKey:@"postalCode" equalTo:zipcode];
        }
        isShowNoData = YES;
    }
    if (isSelected) {
        [queryTotal whereKey:@"favoritors" containsAllObjectsInArray:@[[PFUser currentUser].objectId]];
    }
    
    if (categoryList.count > 0) {
        [queryTotal whereKey:@"category" containedIn:categoryList];
    }
    if (condition < 2) {
        [queryTotal whereKey:@"condition" equalTo:[NSNumber numberWithBool:(condition == 0)]];
    }
    rangeIndex = rangindex;
    if(rangindex >= 0) {
        switch (rangindex) {
            case 0: // Town
                if (localityStr != nil) {
                    [queryTotal whereKey:@"locality" equalTo:localityStr];
                }
                break;
            case 1: // City
                break;
            case 2: // State
                if (adminAreaStr != nil) {
                    [queryTotal whereKey:@"adminArea" equalTo:adminAreaStr];
                }
                break;
            case 3: // Country
                if (countryStr != nil) {
                    [queryTotal whereKey:@"country" equalTo:countryStr];
                }
                break;
            case 4: // World
                break;
            default:
                break;
        }
    }
    
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    queryTotal.limit = 100;
    
    NSString *model = [[UIDevice currentDevice] model];
    if (![model isEqualToString:@"iPhone Simulator"]) {
        [self.tableView triggerPullToRefresh];
    }
}

#pragma mark - ProductTableViewCellDelegate

- (void)onFavoriteCheck:(NSInteger)index isFavorite:(BOOL)isFv
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"index %ld is check %d", (long)index, isFv);
    if(isFv)
    {
        NSMutableArray *array = [[productData objectAtIndex:index] objectForKey:@"favoritors"];
        if(array == nil)
            array = [[NSMutableArray alloc] init];
        [array addObject:[PFUser currentUser].objectId];
        PFObject *item = [productData objectAtIndex:index];
        item[@"favoritors"] = array;
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (succeeded) {
                
            }
        }];
        
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
            [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (succeeded) {
                    
                }
            }];
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
    isSearchNavi = YES;
    _isNewSearch = NO;
    [self.productSearchBar resignFirstResponder];
    [self filterResults:searchBar.text];
   
}

// called when bookmark button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isSearchNavi = NO;
    _isNewSearch = NO;
    [productData removeAllObjects];
    queryTotal = [ProductInformation query];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    queryTotal.limit = 100;
    [self loadProductList];
}

#pragma mark - Notification handling
- (void)handleBacklink:(NSDictionary *)backlinkDict {
    NSLog(@"backlinkDict %@", backlinkDict);
}

@end
