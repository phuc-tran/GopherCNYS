//
//  AddNewSearchViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "AddNewSearchViewController.h"

@interface AddNewSearchViewController ()

@end

@implementation AddNewSearchViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view.layer setMasksToBounds:YES];
    [self.view.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.view.layer setBorderWidth: 1.0];
    [self.view.layer setCornerRadius:8.0];
    self.view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.view.layer.shadowOpacity = 0.6f;
    
    self.milesLabel.text = [NSString stringWithFormat:@"%.0f miles", self.milesSlider.value];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closePopup:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate cancelButtonClicked:self];
    }
}

- (IBAction)sliderMilesChangeValue:(UISlider*)sender {
    NSLog(@"%.0f", sender.value);
    self.milesLabel.text = [NSString stringWithFormat:@"%.0f miles", sender.value];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)handleTap:(id)sender {
    [self.view endEditing:true];
}

@end
