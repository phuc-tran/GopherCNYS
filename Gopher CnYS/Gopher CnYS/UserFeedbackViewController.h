//
//  UserFeedbackViewController.h
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//


#import "JSQMessages.h"
#import <Parse/Parse.h>

@interface UserFeedbackViewController : JSQMessagesViewController

@property (nonatomic, strong) PFUser *curUser;

@end
