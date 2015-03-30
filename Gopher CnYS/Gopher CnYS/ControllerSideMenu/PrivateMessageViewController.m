//
//  PrivateMessageViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 3/28/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "PrivateMessageViewController.h"
#import "MBProgressHUD.h"


@interface PrivateMessageViewController ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) JSQMessagesAvatarImage *outgoingAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *incomingAvatar;

@end

@implementation PrivateMessageViewController



#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.title = @"JSQMessages";
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [[PFUser currentUser] valueForKey:@"objectId"];
    self.senderDisplayName = [[PFUser currentUser] valueForKey:@"username"];
    
    UIImage *profileAvatar = [[PFUser currentUser] valueForKey:@"profileImage"];
    if (profileAvatar != nil) {
        self.outgoingAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:profileAvatar
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
    else {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.outgoingAvatar = nil;
    }

    if (self.incomingImage) {
        self.incomingAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:self.incomingImage
                                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
    else {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.incomingAvatar = nil;
    }
    
    self.showLoadEarlierMessagesHeader = NO;
    
    self.messages = [[NSMutableArray alloc] init];
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:64.0/255.0 green:222.0/255.0 blue:172.0/255.0 alpha:1.0]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0]];
 
//    [self loadProductInfo];
//    [self loadMessages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [button addTarget:self action:@selector(leftBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadProductInfo {
    // Product info
    if (self.product) {
        PFFile *imageFile = [self.product objectForKey:@"photo1"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.conversationImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:78];
            }
        }];
        
        self.conversationTitleLabel.text = [self.product valueForKey:@"title"];
        self.conversationDescLabel.text = [[self.product objectForKey:@"description"] description];
        self.conversationPriceLabel.text = [NSString stringWithFormat:@"%ld", (long)[[self.product valueForKey:@"price"] integerValue]];
        self.priceSign.hidden = NO;
    }
    else {
        // Get Product if there is no product set
        PFQuery *query = [PFQuery queryWithClassName:@"Products"];
        [query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
        [query whereKey:@"objectId" equalTo:[[self.chatRoom valueForKey:@"listingId"] valueForKey:@"objectId"]];
        [query selectKeys:@[@"description", @"title", @"photo1", @"price"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                // The find succeeded.
                NSLog(@"found product %@", objects);
                
                PFFile *imageFile = [objects[0] objectForKey:@"photo1"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.conversationImageView.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:78];
                    }
                }];
                
                self.conversationTitleLabel.text = [objects[0] valueForKey:@"title"];
                self.conversationDescLabel.text = [[objects[0] objectForKey:@"description"] description];
                self.conversationPriceLabel.text = [NSString stringWithFormat:@"%ld", (long)[[objects[0] valueForKey:@"price"] integerValue]];
                self.priceSign.hidden = NO;
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

- (void)loadMessages {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // Chat history
    if (self.chatRoom) {
        PFQuery *messageQuery = [PFQuery queryWithClassName:@"ChatHistory"];
        [messageQuery whereKey:@"roomId" equalTo:self.chatRoom];
        [messageQuery orderByAscending:@"updatedAt"];
        [messageQuery includeKey:@"writer"];
        
        [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu chatHistories.", (unsigned long)objects.count);
                // Reset self.messages
                [self.messages removeAllObjects];
                
                for (int i = 0; i < objects.count; i++) {
                    PFObject *iMessage = objects[i];
                    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[[iMessage valueForKey:@"writer"] valueForKey:@"objectId"]
                                                             senderDisplayName:[[iMessage valueForKey:@"writer"] valueForKey:@"username"]
                                                                          date:[iMessage valueForKey:@"updatedAt"]
                                                                          text:[iMessage valueForKey:@"message"]];
                    NSLog(@"message %@", message);
                    [self.messages addObject:message];
                }
                [self.collectionView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        // Load chat room from product
        if (self.product) {
            PFQuery *chatroomQuery = [PFQuery queryWithClassName:@"ChatRoom"];
            [chatroomQuery whereKey:@"listingId" equalTo:self.product];
            [chatroomQuery whereKey:@"seller" equalTo:[self.product valueForKey:@"seller"]];
            [chatroomQuery whereKey:@"buyer" equalTo:[PFUser currentUser]];
            
            PFQuery *chatHistoryQuery = [PFQuery queryWithClassName:@"ChatHistory"];
            [chatHistoryQuery whereKey:@"roomId" matchesQuery:chatroomQuery];
            [chatHistoryQuery orderByAscending:@"updatedAt"];
            [chatHistoryQuery includeKey:@"writer"];
            
            [chatHistoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %lu chatHistories.", (unsigned long)objects.count);
                    // Reset self.messages first
                    [self.messages removeAllObjects];
                    
                    for (int i = 0; i < objects.count; i++) {
                        PFObject *iMessage = objects[i];
                        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[[iMessage valueForKey:@"writer"] valueForKey:@"objectId"]
                                                                 senderDisplayName:[[iMessage valueForKey:@"writer"] valueForKey:@"username"]
                                                                              date:[iMessage valueForKey:@"updatedAt"]
                                                                              text:[iMessage valueForKey:@"message"]];
                        NSLog(@"message %@", message);
                        [self.messages addObject:message];
                    }
                    [self.collectionView reloadData];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                
                
                // If there is no chat room yet, create one
                
            }];
        }
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
//    [self.demoData.messages addObject:message];
    
    [self.messages addObject:message];
    
    // Save to Parse
//    PFObject *chatHistory = [PFObject objectWithClassName:@"ChatHistory"];
//    chatHistory[@"message"] = message.text;
//
//    PFRelation *writerRelation = [chatHistory relationForKey:@"writer"];
//    [writerRelation addObject:[PFUser currentUser]];
//    
//    PFRelation *roomIdRelation = [chatHistory relationForKey:@"roomId"];
//    [roomIdRelation addObject:self.chatRoom];
//    
//    [chatHistory saveInBackground];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
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
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingAvatar;
    }
    else {
        return self.incomingAvatar;
    }
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
    
//    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
//    
//    /**
//     *  iOS7-style sender name labels
//     */
//    if ([message.senderId isEqualToString:self.senderId]) {
//        return nil;
//    }
//    
//    if (indexPath.item - 1 > 0) {
//        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
//        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
//            return nil;
//        }
//    }
//    
//    /**
//     *  Don't specify attributes to use the defaults.
//     */
//    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
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
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
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
//    if (indexPath.item % 3 == 0) {
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;
//    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
    /**
     *  iOS7-style sender name labels
     */
//    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
//    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
//        return 0.0f;
//    }
//    
//    if (indexPath.item - 1 > 0) {
//        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
//        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
//            return 0.0f;
//        }
//    }
//    
//    return kJSQMessagesCollectionViewCellLabelHeightDefault;
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

@end
