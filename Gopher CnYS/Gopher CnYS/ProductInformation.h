//
//  ProductInformation.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/12/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <Parse/Parse.h>


@interface ProductInformation : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *locality;
@property (nonatomic, retain) NSString *adminArea;
@property (nonatomic, retain) NSArray *favoritors;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSNumber *category;
@property (nonatomic, retain) PFFile *photo1;
@property (nonatomic, retain) PFFile *photo2;
@property (nonatomic, retain) PFFile *photo3;
@property (nonatomic, retain) PFFile *photo4;


@end
