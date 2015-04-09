//
//  UserFeedbackViewController.h
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//


#import "JSQMessages.h"
#import <Parse/Parse.h>

@interface CommentViewController : JSQMessagesViewController

@property (nonatomic, strong) UIImage *userInfoImage;
@property (nonatomic, strong) NSString *productId;

@end
