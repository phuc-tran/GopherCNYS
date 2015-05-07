//
//  AddNewSearchViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol AddNewSearchViewControllerDelegate;

@interface AddNewSearchViewController : UIViewController <UITextFieldDelegate>
{
    BOOL isNotify;
}

@property (assign, nonatomic) id <AddNewSearchViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
@property (weak, nonatomic) IBOutlet UILabel *milesLabel;
@property (weak, nonatomic) IBOutlet UITextField *tabNameField;
@property (weak, nonatomic) IBOutlet UITextField *keywordsField;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton1;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton2;

@end


@protocol AddNewSearchViewControllerDelegate<NSObject>
@optional
- (void)cancelButtonClicked:(AddNewSearchViewController*)viewController;
- (void)addTabButtonClicked:(AddNewSearchViewController*)viewController;
@end