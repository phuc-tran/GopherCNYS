//
//  ProfileViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProfileViewController.h"
#import "HomeViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profileImageView.layer.cornerRadius = 5.0f;
    self.profileImageView.layer.borderWidth = 2.0f;
    self.profileImageView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.profileImageView.clipsToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self setupLeftBackBarButtonItem];
    self.navigationController.navigationBar.hidden = YES;
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"profile_from_login" sender:self];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *name  = [currentUser objectForKey:@"name"];
    if (name == nil) {
        name = currentUser.username;
    }
    self.usernameLable.text = name;
    self.emailLable.text = currentUser.email;
}

#pragma mark - Self action
- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (IBAction)backBtnClick:(id)sender {
    [self leftBackClick:nil];
}

- (IBAction)updateAvatarBtnClick:(UIButton*)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Update avatar profile" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheet.tag = sender.tag;
    [actionSheet showInView:self.view];
}

- (IBAction)defaultLocationClick:(UIButton*)sender {
    
}

- (IBAction)userfollowClick:(UIButton*)sender {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *gotImage = info[UIImagePickerControllerOriginalImage];
    self.profileImageView.image = gotImage;
}

#pragma mark - UIActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button at index: %ld clicked\nIts title is '%@'", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    switch (buttonIndex) {
        case 0: // Take photo
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
                imagePicker.allowsEditing = true;
                imagePicker.view.tag = actionSheet.tag;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
            break;
        case 1: //Choose Existing
        {
            UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
            pickerC.delegate = self;
            pickerC.view.tag = actionSheet.tag;
            [self presentViewController:pickerC animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"profile_from_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }
}

@end


