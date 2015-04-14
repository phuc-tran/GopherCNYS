//
//  ProductInformation.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/12/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductInformation.h"
#import <Parse/PFObject+Subclass.h>

@implementation ProductInformation

@dynamic title;
@dynamic locality;
@dynamic price;
@dynamic adminArea;
@dynamic favoritors;
@dynamic category;
@dynamic photo1, photo2, photo3, photo4;

+ (void)load {
    [self registerSubclass];
}

# pragma mark - Setters and Getters
+ (NSString *)parseClassName {
    return @"Products";
}

@end
