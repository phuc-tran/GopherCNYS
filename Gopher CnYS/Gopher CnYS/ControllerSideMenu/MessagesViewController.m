//
//  MessagesViewController.m
//  RESideMenuStoryboards
//
//  Created by Trần Huy Phúc on 3/21/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageTableViewCell.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "PrivateMessageViewController.h"
#import "HomeViewController.h"

@interface MessagesViewController ()

@property (nonatomic, weak) IBOutlet UITableView *messagesListTable;
@property (nonatomic, strong) NSMutableArray *messagesList;
@property (nonatomic, strong) PFFile *selectedProfileImage;
@property (nonatomic, strong) NSString *selectedProfileImageURL;
@property (nonatomic, strong) PFObject *selectedChatRoom;
@property (nonatomic, strong) NSString *selectedUserId;
@property (nonatomic, strong) NSString *selectedFBId;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messagesListTable.allowsMultipleSelectionDuringEditing = NO;
    [self.messagesListTable registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"MessageListCell"];
    self.messagesListTable.rowHeight = 83.0f;
    self.messagesListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupLeftBackBarButtonItem];
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"message_from_login" sender:self];
    } else {
        // Get list of messages
        [self loadMessagesList];
    }
}

- (IBAction)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void) loadMessagesList {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *buyerQuery = [PFQuery queryWithClassName:@"Chatroom"];
    [buyerQuery whereKey:@"buyer" equalTo:[PFUser currentUser]];
//    [buyerQuery includeKey:@"seller"];
    
    PFQuery *sellerQuery = [PFQuery queryWithClassName:@"Chatroom"];
    [sellerQuery whereKey:@"seller" equalTo:[PFUser currentUser]];
//    [sellerQuery includeKey:@"buyer"];
    
    PFQuery *messagesListQuery = [PFQuery orQueryWithSubqueries:@[buyerQuery, sellerQuery]];
    [messagesListQuery orderByDescending:@"updatedAt"];
    [messagesListQuery includeKey:@"listingId"];
    
    [messagesListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu chatrooms.", (unsigned long)objects.count);
            NSLog(@"%@", objects);
            self.messagesList = [NSMutableArray arrayWithArray:objects];
            [self.messagesListTable reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
//    PFQuery *messageQuery = [PFQuery queryWithClassName:@"ChatHistory"];
//    [messageQuery whereKey:@"roomId" matchesQuery:messagesListQuery];
//    [messageQuery orderByDescending:@"updatedAt"];
//    [messageQuery includeKey:@"writer"];
//    [messageQuery includeKey:@"roomId"];
//    [messageQuery setLimit:1];
//    
//    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %lu chatrooms.", (unsigned long)objects.count);
//            NSLog(@"%@", objects);
//            self.messagesList = [NSMutableArray arrayWithArray:objects];
//            [self.messagesListTable reloadData];
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
}


#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messagesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"MessageListCell";
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    // Calculate the days / mins / hours of the latest message
    // The maximum days is 7
    NSString *updatedStr = @"";
    NSDate *updated = [self.messagesList[indexPath.row] updatedAt];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:updated
                                                          toDate:[NSDate date]
                                                         options:0];
    if (components.day > 7) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        updatedStr = [dateFormat stringFromDate:updated];
    } else if (components.day > 0) {
        updatedStr = [NSString stringWithFormat:@"%ld d", (long)components.day];
    } else {
        components = [gregorianCalendar components:NSCalendarUnitHour
                                          fromDate:updated
                                            toDate:[NSDate date]
                                           options:0];
        if (components.hour > 0) {
            updatedStr = [NSString stringWithFormat:@"%ld hr", (long)components.hour];
        }
        else {
            components = [gregorianCalendar components:NSCalendarUnitMinute
                                              fromDate:updated
                                                toDate:[NSDate date]
                                               options:0];
            updatedStr = [NSString stringWithFormat:@"%ld m", (long)components.minute];
        }
    }
    cell.timeLabel.text = updatedStr;
    cell.messageLabel.text = [[self.messagesList[indexPath.row] valueForKey:@"listingId"] valueForKey:@"title"];
    cell.avatarImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"avatarDefault"] withDiameter:70];

    PFUser *messenger = [self.messagesList[indexPath.row] valueForKey:@"seller"];
    if ([[messenger valueForKey:@"objectId"] isEqualToString:[[PFUser currentUser] valueForKey:@"objectId"]]) {
        messenger = [self.messagesList[indexPath.row] valueForKey:@"buyer"];
    }

    [messenger fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
//        NSLog(@"messenger %@", [messenger valueForKey:@"username"]);
        PFFile *profileAvatar = [messenger valueForKey:@"profileImage"];
        if (profileAvatar != nil) {
            [profileAvatar getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.avatarImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
                
                }
            }];
        } else {
            NSString *url = [messenger objectForKey:@"profileImageURL"];
            if (url.length > 0) {
//                [self loadAvatar:url withImage:cell.avatarImageView];
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadImageWithURL:[NSURL URLWithString:url]
                                      options:0
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                         // progression tracking code
                                     }
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        if (image) {
                                            cell.avatarImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
                                        }
                                    }];
            }
            else {
                // load fb avatar
                NSString *fbId = [messenger objectForKey:@"fbId"];
                if (fbId && fbId.length > 0) {
//                    [self loadfbAvatar:fbId withImage:cell.avatarImageView];
                    NSString *fbURLImage = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", fbId];
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fbURLImage]] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                        NSLog(@"response %@", [[response URL] absoluteString]);
//                        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[[response URL] absoluteString]]];
                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                        [manager downloadImageWithURL:[NSURL URLWithString:[[response URL] absoluteString]]
                                              options:0
                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                 // progression tracking code
                                             }
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                if (image) {
                                                    cell.avatarImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
                                                }
                                            }];
                    }];
                }
            }
        }
        
    }];
    
    
//    NSString *statusStr = [[self.messagesList [indexPath.row] valueForKey:@"roomId"] valueForKey:@"new"];
    NSString *statusStr = [self.messagesList [indexPath.row] valueForKey:@"new"];
    if ([statusStr caseInsensitiveCompare:@"read"] == NSOrderedSame) {
        cell.isRead = YES;
    }
    else {
        cell.isRead = NO;
    }
    
//    NSLog(@"room %@ || name %@", [[self.messagesList[indexPath.row] valueForKey:@"roomId"] valueForKey:@"objectId"], [messenger valueForKey:@"username"]);
    
//    NSLog(@"new value %@", [[self.messagesList [indexPath.row] valueForKey:@"roomId"] valueForKey:@"new"]);
    
    
//    NSLog(@"createAt %@ || user: %@ || message %@ -------- %f", updatedStr, [[self.messagesList[indexPath.row] valueForKey:@"writer"] valueForKey:@"username"], [self.messagesList[indexPath.row] valueForKey:@"message"], [updated timeIntervalSinceNow]);
    
    
    
    return cell;

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSLog(@"aww, delete hit");
        
        // Delete messages on Parse
        PFQuery *chatHistoryQuery = [PFQuery queryWithClassName:@"ChatHistory"];
//        [chatHistoryQuery whereKey:@"roomId" equalTo:[self.messagesList[indexPath.row] valueForKey:@"roomId"]];
        [chatHistoryQuery whereKey:@"roomId" equalTo:self.messagesList[indexPath.row]];
        [chatHistoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error) {
                for (PFObject *object in objects) {
                    NSLog(@"delete chat history %@", [object valueForKey:@"objectId"]);
                    [object deleteInBackground];
                }
            }
        }];
        PFObject *chatroom = [PFObject objectWithoutDataWithClassName:@"Chatroom" objectId:[self.messagesList[indexPath.row] valueForKey:@"objectId"]];
        NSLog(@"chatroom to delete %@", [chatroom valueForKey:@"objectId"]);
        [chatroom deleteInBackground];
        
        // Refresh UI
        [self.messagesList removeObjectAtIndex:indexPath.row];
        [self.messagesListTable reloadData];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFUser *messenger = [self.messagesList[indexPath.row] valueForKey:@"seller"];
    if ([[messenger valueForKey:@"objectId"] isEqualToString:[[PFUser currentUser] valueForKey:@"objectId"]]) {
        messenger = [self.messagesList[indexPath.row] valueForKey:@"buyer"];
    }
    
    [messenger fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        PFFile *profileAvatar = [messenger valueForKey:@"profileImage"];
        self.selectedProfileImage = profileAvatar;

        self.selectedProfileImageURL = [messenger objectForKey:@"profileImageURL"];
        
        self.selectedFBId = [messenger objectForKey:@"fbId"];
        
        self.selectedChatRoom = self.messagesList[indexPath.row];
        
        self.selectedUserId = messenger.objectId;
        
        [self performSegueWithIdentifier:@"message_to_coversation" sender:self];
    }];
    
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"message_to_coversation"]) {
         PrivateMessageViewController *destViewController = (PrivateMessageViewController *)[segue destinationViewController];
         destViewController.incomingImage = self.selectedProfileImage;
         destViewController.chatRoom = self.selectedChatRoom;
         destViewController.incomingImageURLStr = self.selectedProfileImageURL;
         destViewController.incomingSenderID = self.selectedUserId;
         destViewController.incomingfbId = self.selectedFBId;
     }
     else if ([segue.identifier isEqualToString:@"message_from_login"]) {
         HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
         destViewController.shouldGoBack = YES;
     }
 }


@end
