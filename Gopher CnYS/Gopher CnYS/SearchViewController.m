//
//  SearchViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SearchViewController.h"
#import "HomeViewController.h"

@interface SearchViewController ()
{
    NSArray *categoryData;
    NSMutableArray *categorySelectedList;
}
@end

@implementation SearchViewController

@synthesize favButton;
@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    categoryData = [NSArray arrayWithObjects:@"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Town", @"City", @"State", @"Country", @"World"]];
    segmentedControl.frame = CGRectMake(0, 0, self.rangeSegmentControl.frame.size.width, self.rangeSegmentControl.frame.size.height);
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectedSegmentIndex = 3;
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.rangeSegmentControl addSubview:segmentedControl];
    
    categorySelectedList = [[NSMutableArray alloc] init];
    BOOL b = FALSE;
    for (int i = 0; i < categoryData.count; i++) {
        [categorySelectedList addObject:[NSNumber numberWithBool:b]];
    }
    self.conditionSegmentControl.selectedSegmentIndex = 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super setupLeftBackBarButtonItem];
    [self.categoryCollectionView reloadData];
    
    if (![self checkIfUserLoggedIn]) {
        self.favButton.hidden = YES;
    } else {
        self.favButton.hidden = NO;
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
    if ([segue.identifier isEqualToString:@"search_from_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }
}

#pragma mark - UICollectionViewDataSource
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (IBAction)conditionControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld ", (long)segmentedControl.selectedSegmentIndex);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return categoryData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCollectionViewCell *cell = (CategoryCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CategoriesSearchCell" forIndexPath:indexPath];
    cell.categoryLable.text = categoryData[indexPath.row];
    cell.cellIndex = indexPath.row;
    cell.delegate = self;
    [cell update:[[categorySelectedList objectAtIndex:indexPath.row] boolValue]];
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)favButtonClick:(id)sender {
    isFavoriteSelected = !isFavoriteSelected;
    if(isFavoriteSelected) {
        [favButton setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateNormal];
        [favButton setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateHighlighted];
        [favButton setImage:[UIImage imageNamed:@"ic_favorite_filter.png"] forState:UIControlStateSelected];
    } else {
        [favButton setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateNormal];
        [favButton setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateHighlighted];
        [favButton setImage:[UIImage imageNamed:@"ic_favorite_filter1.png"] forState:UIControlStateSelected];
    }
}

- (IBAction)categorySelectAllClick:(id)sender {
    for (int i = 0; i < categorySelectedList.count; i++) {
        BOOL isSelected = YES;
        [categorySelectedList replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:isSelected]];
    }
    [self.categoryCollectionView reloadData];
}

- (IBAction)categoryResetClick:(id)sender {
    for (int i = 0; i < categorySelectedList.count; i++) {
        BOOL isSelected = NO;
        [categorySelectedList replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:isSelected]];
    }
    [self.categoryCollectionView reloadData];
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}

- (IBAction)submitButtonClick:(id)sender {
    if (![self isNumeric:self.priceField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Price input must be number format" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSMutableArray *categoryList = [[NSMutableArray alloc] init];
    for (int i = 0; i < categorySelectedList.count; i++) {
        BOOL isSelected = [[categorySelectedList objectAtIndex:i] boolValue];
        if (isSelected) {
            [categoryList addObject:[NSNumber numberWithInt:(i+1)]];
        }

    }
    if(delegate != nil)
        [delegate onFilterContentForSearch:categoryList withPrice:[self.priceField.text integerValue] withZipCode:self.zipCodeField.text withKeyword:self.keywordField.text favoriteSelected:isFavoriteSelected conditionOption:self.conditionSegmentControl.selectedSegmentIndex];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)leftBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CategoryCollectionViewCellDelegate
- (void)onCellSelect:(NSInteger)index {
    BOOL isSelected = [[categorySelectedList objectAtIndex:index] boolValue];
    isSelected = !isSelected;
    [categorySelectedList replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:isSelected]];
    [self.categoryCollectionView reloadData];
}

@end
