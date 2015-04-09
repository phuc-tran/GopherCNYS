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
    
    self.milesSlider.value = self.milesSlider.maximumValue/2.0f;
    
    self.milesLabel.text = [NSString stringWithFormat:@"%.0f miles", self.milesSlider.value];
    
    isNotify = NO;
    if(isNotify) {
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateNormal];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateSelected];
        
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateNormal];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateSelected];
        
    } else {
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateNormal];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateSelected];
        
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateNormal];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateSelected];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveSearchTabList{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"searchtab.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"searchtab" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:nil];
        NSLog(@"File did not exist! Default copied...");
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSArray *searchTabList = [dict objectForKey:@"search_tab"];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:searchTabList];
    
    //Create a new Dictionary
    NSMutableDictionary *newTab = [[NSMutableDictionary alloc] init];
    
    [newTab setObject:self.tabNameField.text forKey:@"name"];
    [newTab setObject:self.keywordsField.text forKey:@"keywords"];
    [newTab setObject:[NSNumber numberWithFloat:self.milesSlider.value] forKey:@"distance"];
    [newTab setValue:@(isNotify) forKey:@"notify"];
    
    //add dictionary to array
    [tempArray addObject:newTab];
    
    //set the new array for location key
    [dict setObject:tempArray forKey:@"search_tab"];
    
    //update the plist
    [dict writeToFile:path atomically:true];
}

- (IBAction)notifyClick:(id)sender
{
    isNotify = !isNotify;
    if(isNotify) {
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateNormal];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateSelected];
        
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateNormal];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateSelected];
        
    } else {
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateNormal];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton1 setImage:[UIImage imageNamed:@"search_unnotify.png"] forState:UIControlStateSelected];
        
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateNormal];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateHighlighted];
        [self.notifyButton2 setImage:[UIImage imageNamed:@"search_notify.png"] forState:UIControlStateSelected];
    }
    
}

- (IBAction)closePopup:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate cancelButtonClicked:self];
    }
}

- (IBAction)addTabClick:(id)sender
{
    if (self.tabNameField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input tab search name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self saveSearchTabList];
    [self closePopup:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(addTabButtonClicked:)]) {
        [self.delegate addTabButtonClicked:self];
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
