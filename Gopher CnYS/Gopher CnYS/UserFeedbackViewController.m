//
//  UserFeedbackViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "UserFeedbackViewController.h"
#import "HomeViewController.h"
#import <Parse/Parse.h>

@interface UserFeedbackViewController ()

@property (nonatomic, strong) NSMutableArray *feedbacks;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) JSQMessagesAvatarImage *outgoingAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *incomingAvatar;

@end

//@property (weak, nonatomic, readonly) UIImageView *conversationImageView;
//@property (weak, nonatomic, readonly) UILabel *conversationTitleLabel;
//@property (weak, nonatomic, readonly) UILabel *conversationDescLabel;
//@property (weak, nonatomic, readonly) UILabel *conversationPriceLabel;
//@property (weak, nonatomic, readonly) UIImageView *priceSign;


@implementation UserFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    self.conversationTitleLabel.textColor = [UIColor colorWithRed:64.0f/255.0f green:222.0f/255.0f blue:172.0f/255.0f alpha:1.0f];
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = @"it-should-not-be-current-id";
    self.senderDisplayName = @"anonymous";
    
    // NO avatars
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.incomingAvatar = nil;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.outgoingAvatar = nil;
    self.showLoadEarlierMessagesHeader = NO;
    
    self.feedbacks = [[NSMutableArray alloc] init];
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [button addTarget:self action:@selector(leftBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    if (![self checkIfUserLoggedIn]) {
        [self performSegueWithIdentifier:@"userFeedback_to_login" sender:self];
    } else {
        [self loadUserProfile];
        [self loadFeedbacks];
    }
}


- (IBAction)leftBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkIfUserLoggedIn
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        return YES;
    }
    return NO;
}

- (void)loadUserProfile {
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[self.curUser objectId]];
    [query selectKeys:@[@"username", @"name", @"profileImage"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            PFUser *user = [objects objectAtIndex:0];
            NSString *name = [user valueForKey:@"name"];
            if (name == nil) {
                name = user.username;
            }
            self.conversationTitleLabel.text = name;
            PFFile *imageFile = [user objectForKey:@"profileImage"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    if (data != nil) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.conversationImageView.image = image;
                    }
                }
            }];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)loadFeedbacks {
    
    for (int i = 0; i < 3; i++) {
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"abcxyz"
                                                 senderDisplayName:@"loi nhu don"
                                                              date:[NSDate date]
                                                              text:[NSString stringWithFormat:@"this is feedback number %d", i]];
        NSLog(@"message %@", message);
        [self.feedbacks addObject:message];
    }
    [self.collectionView reloadData];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];

    // set senderId and display name with current user's because they were set different value for the controller
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[[PFUser currentUser] valueForKey:@"objectId"]
                                             senderDisplayName:[[PFUser currentUser] valueForKey:@"username"]
                                                          date:date
                                                          text:text];
    
    //    [self.demoData.messages addObject:message];
    
    [self.feedbacks addObject:message];
    
//    // Save to Parse: ChatHistory
//    PFObject *chatHistory = [PFObject objectWithClassName:@"ChatHistory"];
//    chatHistory[@"message"] = message.text;
//    chatHistory[@"writer"] = [PFUser currentUser];
//    chatHistory[@"roomId"] = self.chatRoom;
//    [chatHistory saveInBackground];
//    
//    // Mark chat room as new
//    PFObject *chatroom = [PFObject objectWithoutDataWithClassName:@"Chatroom" objectId:[self.chatRoom valueForKey:@"objectId"]];
//    chatroom[@"new"] = @"new";
//    [chatroom saveInBackground];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.feedbacks objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.feedbacks objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    //    if (indexPath.item % 3 == 0) {
    //        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    //        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    //    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.feedbacks.count;
    //    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.feedbacks objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
        }
        else {
            cell.textView.textColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"userFeedback_to_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }
}

@end
