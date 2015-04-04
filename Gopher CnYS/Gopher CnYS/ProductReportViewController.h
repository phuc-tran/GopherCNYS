//
//  ProductReportViewController.h
//  GopherCNYS
//
//  Created by Vu Tiet on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "BaseViewController.h"
#import <MessageUI/MessageUI.h>

@interface ProductReportViewController : BaseViewController <UITextViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) PFObject *product;
@property (nonatomic, strong) UIImage *productImage;
@property (nonatomic, strong) NSString *sellerName;
@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UITextField *productDesc;
@property (nonatomic, weak) IBOutlet UILabel *productPrice;
@property (nonatomic, weak) IBOutlet UILabel *productDistance;
@property (nonatomic, weak) IBOutlet UITextField *productFeedback;
@property (nonatomic, weak) IBOutlet UILabel *productName;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

@end
