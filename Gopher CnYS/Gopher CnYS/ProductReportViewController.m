//
//  ProductReportViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductReportViewController.h"
#import <Parse/Parse.h>

@interface ProductReportViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) UITextView *activeField;
@property (nonatomic, strong) PFGeoPoint *currentLocaltion;

@end

@implementation ProductReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    
    self.productFeedback.layer.borderWidth = 1.0f;
    self.productFeedback.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.productName.text = [self.product valueForKey:@"title"];;
    self.productDesc.text = [[self.product objectForKey:@"description"] description];
    NSInteger price  = [[self.product valueForKey:@"price"] integerValue];
    self.productPrice.text = [NSString stringWithFormat:@"$%ld", (long)price];
    PFGeoPoint *positionItem  = [self.product objectForKey:@"position"];
    self.productDistance.text = [NSString stringWithFormat:@"%.f miles", [self.currentLocaltion distanceInMilesTo:positionItem]];
    self.productImageView.image = self.productImage;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super setupLeftBackBarButtonItem];
}

- (IBAction)leftBackClick:(UIBarButtonItem *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate
//- (IBAction)text:(id)sender)
//{
//    if (textField == self.productFeedback && textField.text.length > 0) {
//        [self submitButtonDidTouch:nil];
//    }
//    
//    return YES;
//}


- (IBAction)textViewDidEndEditing:(UITextView *)textView
{
    self.activeField = nil;
}

- (IBAction)textViewDidBeginEditing:(UITextView *)textView {
    self.activeField = textView;

}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.submitButton.enabled = YES;
    }
    else {
        self.submitButton.enabled = NO;
    }
}

#pragma mark - Keyboard Handler
- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.contentScrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void) keyboardDidHide:(NSNotification *)note {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)handleTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)submitButtonDidTouch:(id)sender {
    // Open email composer
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"report@gopherclassifieds.com"]];
        [composeViewController setSubject:@"Customer report"];
        NSString *bodyText = [NSString stringWithFormat:@"%@\nlistingId:%@\nuserId:%@\nusername:%@\nsender userId:%@\nsender username:%@", self.productFeedback.text, [self.product valueForKey:@"objectId"], [[self.product valueForKey:@"seller"] valueForKey:@"objectId"], self.sellerName, [[PFUser currentUser]objectId], [[PFUser currentUser] username]];
        NSLog(@"bodyText %@", bodyText);
        [composeViewController setMessageBody:bodyText isHTML:NO];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
