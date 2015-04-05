//
//  SearchViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()
{
    NSArray *categoryData;
    NSMutableArray *categorySelectedList;
}
@end

@implementation SearchViewController

@synthesize favButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    categoryData = [NSArray arrayWithObjects:@"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Cameras & Optics", @"Electronics", @"Farmers Market", @"Furniture", @"Hardware", @"Health & Beauty", @"Home & Garden", @"Luggage & Bags", @"Media", @"Office Supplies", @"Pets and Accessories", @"Religious & Ceremonial", @"Seasonal Items", @"Software", @"Sporting Goods", @"Toys & Games", @"Vehicles & Parts", nil];
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Town", @"City", @"State", @"Country", @"World"]];
    segmentedControl.frame = CGRectMake(0, 0, self.rangeSegmentControl.frame.size.width, self.rangeSegmentControl.frame.size.height);
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.backgroundColor = [UIColor clearColor];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.rangeSegmentControl addSubview:segmentedControl];
    
    categorySelectedList = [[NSMutableArray alloc] init];
    BOOL b = FALSE;
    for (int i = 0; i < categoryData.count; i++) {
        [categorySelectedList addObject:[NSNumber numberWithBool:b]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
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
}

- (IBAction)categoryResetClick:(id)sender {
}

#pragma mark - CategoryCollectionViewCellDelegate
- (void)onCellSelect:(NSInteger)index {
    BOOL isSelected = [[categorySelectedList objectAtIndex:index] boolValue];
    isSelected = !isSelected;
    [categorySelectedList replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:isSelected]];
    [self.categoryCollectionView reloadData];
}

@end
