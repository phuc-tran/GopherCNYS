//
//  AddNewSearchViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNewSearchViewControllerDelegate;

@interface AddNewSearchViewController : UIViewController <UITextFieldDelegate>

@property (assign, nonatomic) id <AddNewSearchViewControllerDelegate>delegate;

@end


@protocol AddNewSearchViewControllerDelegate<NSObject>
@optional
- (void)cancelButtonClicked:(AddNewSearchViewController*)iewController;
@end