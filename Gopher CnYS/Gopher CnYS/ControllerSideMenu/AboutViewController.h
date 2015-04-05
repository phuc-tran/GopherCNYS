//
//  AboutViewController.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MessageUI/MessageUI.h>

@interface AboutViewController : BaseViewController <MFMailComposeViewControllerDelegate>

- (IBAction)pushViewController:(id)sender;

@end
