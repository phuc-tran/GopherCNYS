//
//  UserFeedbackViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 3/31/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "CommentViewController.h"
#import "HomeViewController.h"
#import "CommentCollectionViewCell.h"
#import <Parse/Parse.h>

@interface CommentViewController ()

//@property (nonatomic, strong) NSMutableArray *feedbacks;
@property (nonatomic, strong) NSMutableArray *comments;
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


@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView registerNib:[UINib nibWithNibName:@"CommentCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CommentCollectionViewCellIdentifier"];
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
    
    self.comments = [[NSMutableArray alloc] init];
    
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
    
    [self setupHeader];

    [self loadComments];
    
//    NSLog(@"self.view frame %@", NSStringFromCGRect(self.view.frame));
}


- (void)setupHeader {
    if (![self.view viewWithTag:2512]) {
        //        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 104)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        imageView.image = self.userInfoImage;
        [self.view insertSubview:imageView belowSubview:self.collectionView];
        imageView.tag = 2512;
        
        // hide the redundant view
        self.conversationInfoView.hidden = YES;
    }
    
    if (![self.view viewWithTag:2712]) {
        UIView *commentButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 124, CGRectGetWidth(self.view.bounds), 51)];
        [self.view addSubview:commentButtonView];
        
        // Background
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(commentButtonView.frame), CGRectGetHeight(commentButtonView.frame))];
        bgImageView.image = [UIImage imageNamed:@"comment_button_bg.png"];
        [commentButtonView addSubview:bgImageView];
        
        // Button
        UIButton *invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [invisibleButton addTarget:self action:@selector(hideCommentDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        invisibleButton.frame = CGRectMake(0, 0, CGRectGetWidth(commentButtonView.frame), CGRectGetHeight(commentButtonView.frame));
        [commentButtonView addSubview:invisibleButton];
        //        [invisibleButton setBackgroundColor:[UIColor redColor]];
        //        commentButtonView.backgroundColor = [UIColor greenColor];
        commentButtonView.tag = 2712;
        
        // Labels
        NSTextAttachment *attachment1 = [[NSTextAttachment alloc] init];
        attachment1.image = [UIImage imageNamed:@"down_arrow.png"];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment1];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"Hide Comments  "];
        [myString appendAttributedString:attachmentString];
        UILabel *hideCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, CGRectGetWidth(commentButtonView.frame), 21)];
        [commentButtonView addSubview:hideCommentLabel];
        hideCommentLabel.attributedText = myString;
        hideCommentLabel.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
        hideCommentLabel.font = [UIFont systemFontOfSize:14];
        hideCommentLabel.numberOfLines = 1;
        hideCommentLabel.textAlignment = NSTextAlignmentCenter;
        
        NSTextAttachment *attachment2 = [[NSTextAttachment alloc] init];
        attachment2.image = [UIImage imageNamed:@"chat_icon.png"];
        attachmentString = [NSAttributedString attributedStringWithAttachment:attachment2];
        [myString setAttributedString:[[NSAttributedString alloc] initWithString:@"Everyone can view these comments. Use "]];
        [myString appendAttributedString:attachmentString];
        [myString appendAttributedString:[[NSAttributedString alloc] initWithString:@" for the personal information."]];
        UILabel *descCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, CGRectGetWidth(commentButtonView.frame), 29)];
        [commentButtonView addSubview:descCommentLabel];
        descCommentLabel.attributedText = myString;
        descCommentLabel.textColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1.0f];
        descCommentLabel.font = [UIFont systemFontOfSize:10];
        descCommentLabel.numberOfLines = 2;
        descCommentLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (IBAction)hideCommentDidTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadComments {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"forProductId" equalTo:self.productId];
    [query includeKey:@"writer"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            for (int i = 0; i < objects.count; i++) {
                PFUser *iUser = [[objects objectAtIndex:i] valueForKey:@"writer"];
                NSString *iName = [iUser valueForKey:@"name"];
                if (iName == nil) {
                    iName = iUser.username;
                }
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:iUser.objectId
                                                         senderDisplayName:iName
                                                                      date:[objects[i] valueForKey:@"createdAt"]
                                                                      text:[objects[i] valueForKey:@"comment"]];
                NSLog(@"message %@", message);
                [self.comments addObject:message];
                
            }
            [self.collectionView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
    
    [self.comments addObject:message];
    
    // Save to Parse: Comments
//    PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
//    newComment[@"comment"] = message.text;
//    newComment[@"writer"] = [PFUser currentUser];
//    newComment[@"forProductId"] = self.productId;
//    [newComment saveInBackground];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.comments objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.comments objectAtIndex:indexPath.item];
    
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
    return self.comments.count;
    //    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
//    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    id<JSQMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    NSParameterAssert(messageItem != nil);
    
    NSString *messageSenderId = [messageItem senderId];
    NSParameterAssert(messageSenderId != nil);
    
    BOOL isOutgoingMessage = [messageSenderId isEqualToString:self.senderId];
    BOOL isMediaMessage = [messageItem isMediaMessage];
    
    NSString *cellIdentifier = @"CommentCollectionViewCellIdentifier";
    
    CommentCollectionViewCell *cell = (CommentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = collectionView;
    
    if (!isMediaMessage) {
        
        // text
        cell.textView.text = [messageItem text];
        
        // Date
        // Calculate the days / mins / hours of the latest message
        // The maximum days is 7
        NSString *updatedStr = @"";
        NSDate *updated = [messageItem date];
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
        cell.dateLabel.text = updatedStr;
        
        // writer
        cell.writerLabel.text = [messageItem senderDisplayName];
                
        if ([[UIDevice currentDevice].systemVersion compare:@"8.0.0" options:NSNumericSearch] == NSOrderedAscending) {
            //  workaround for iOS 7 textView data detectors bug
            cell.textView.text = nil;
            cell.textView.attributedText = [[NSAttributedString alloc] initWithString:[messageItem text]
                                                                           attributes:@{ NSFontAttributeName : collectionView.collectionViewLayout.messageBubbleFont }];
        }
        
        NSParameterAssert(cell.textView.text != nil);
        
        id<JSQMessageBubbleImageDataSource> bubbleImageDataSource = [collectionView.dataSource collectionView:collectionView messageBubbleImageDataForItemAtIndexPath:indexPath];
        if (bubbleImageDataSource != nil) {
            cell.messageBubbleImageView.image = [bubbleImageDataSource messageBubbleImage];
            cell.messageBubbleImageView.highlightedImage = [bubbleImageDataSource messageBubbleHighlightedImage];
        }
    }
    else {
        id<JSQMessageMediaData> messageMedia = [messageItem media];
        cell.mediaView = [messageMedia mediaView] ?: [messageMedia mediaPlaceholderView];
        NSParameterAssert(cell.mediaView != nil);
    }
    
    BOOL needsAvatar = YES;
    if (isOutgoingMessage && CGSizeEqualToSize(collectionView.collectionViewLayout.outgoingAvatarViewSize, CGSizeZero)) {
        needsAvatar = NO;
    }
    else if (!isOutgoingMessage && CGSizeEqualToSize(collectionView.collectionViewLayout.incomingAvatarViewSize, CGSizeZero)) {
        needsAvatar = NO;
    }
    
    id<JSQMessageAvatarImageDataSource> avatarImageDataSource = nil;
    if (needsAvatar) {
        avatarImageDataSource = [collectionView.dataSource collectionView:collectionView avatarImageDataForItemAtIndexPath:indexPath];
        if (avatarImageDataSource != nil) {
            
            UIImage *avatarImage = [avatarImageDataSource avatarImage];
            if (avatarImage == nil) {
                cell.avatarImageView.image = [avatarImageDataSource avatarPlaceholderImage];
                cell.avatarImageView.highlightedImage = nil;
            }
            else {
                cell.avatarImageView.image = avatarImage;
                cell.avatarImageView.highlightedImage = [avatarImageDataSource avatarHighlightedImage];
            }
        }
    }
    
    cell.cellTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath];
    cell.messageBubbleTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:indexPath];
    cell.cellBottomLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForCellBottomLabelAtIndexPath:indexPath];
    
    CGFloat bubbleTopLabelInset = (avatarImageDataSource != nil) ? 60.0f : 15.0f;
    
    if (isOutgoingMessage) {
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, bubbleTopLabelInset);
    }
    else {
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, bubbleTopLabelInset, 0.0f, 0.0f);
    }
    
    cell.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.shouldRasterize = YES;
    
    
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
    
    JSQMessage *msg = [self.comments objectAtIndex:indexPath.item];
    
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

- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = [collectionViewLayout sizeForItemAtIndexPath:indexPath];
    itemSize.height += 30;
    return itemSize;
}


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

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"userFeedback_to_login"]) {
//        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
//        destViewController.shouldGoBack = YES;
//    }
//}

@end
