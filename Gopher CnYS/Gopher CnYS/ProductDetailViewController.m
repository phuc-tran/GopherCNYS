//
//  ProductDetailViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/16/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductDetailViewController.h"
#import <Parse/Parse.h>
@interface ProductDetailViewController ()

@end

@implementation ProductDetailViewController

@synthesize productData, selectedIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Products Detail"];
    
//    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    backbtn.tintColor = [UIColor blackColor];
//    self.navigationItem.backBarButtonItem = backbtn;
}

-(void)viewWillAppear:(BOOL)animated {
    PFFile *imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo1"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.productImgaeView.image = image;
        }
    }];
    
    self.productNameLbl.text = [[productData objectAtIndex:selectedIndex] valueForKey:@"title"];
    self.productDescription.textColor = [UIColor colorWithRed:148/255.0f green:148/255.0f blue:148/255.0f alpha:1.0f];
    self.productDescription.text = [[[productData objectAtIndex:selectedIndex] objectForKey:@"description"] description];
    NSInteger price  = [[[productData objectAtIndex:selectedIndex] valueForKey:@"price"] integerValue];
    self.productPriceLbl.text = [NSString stringWithFormat:@"$%ld", (long)price];
    bool condition = [[productData objectAtIndex:selectedIndex] valueForKey:@"condition"];
    self.productConditionLbl.text = ((condition == true) ? @"Used" : @"");
    NSInteger quantity = [[[productData objectAtIndex:selectedIndex] valueForKey:@"quantity"] integerValue];
    self.productQuantityLbl.text = [NSString stringWithFormat:@"%ld", (long)quantity];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [[productData objectAtIndex:selectedIndex] valueForKey:@"createdAt"];
    self.productPostedLbl.text = [dateformater stringFromDate:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
