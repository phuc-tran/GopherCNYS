//
//  CommentViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 4/5/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "CommentViewController.h"

@interface CommentViewController ()

@property (nonatomic, strong) NSMutableArray *comments;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) JSQMessagesAvatarImage *outgoingAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *incomingAvatar;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"UserFeedbackCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserFeedbackCollectionViewCellIdentifier"];
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
//    self.incomingAvatar = nil;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
//    self.outgoingAvatar = nil;
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

- (void)viewDidAppear:(BOOL)animated {

    NSLog(@"view frame %@", NSStringFromCGSize(self.view.frame.size));
    [self setupHeader];
}

- (void)setupHeader {
    if (![self.view viewWithTag:2512]) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 104)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)hideCommentDidTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
