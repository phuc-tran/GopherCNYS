//
//  CommentViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 4/9/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "CommentViewController.h"
#import <Parse/Parse.h>

@interface CommentViewController ()

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *avatars;
@property (nonatomic, weak) IBOutlet UIView *inputView;
@property (nonatomic, weak) IBOutlet UIView *inputBorderView;
@property (nonatomic, weak) IBOutlet UITextView *inputTextView;
@property (nonatomic, weak) IBOutlet UILabel *hideCommentLabel;
@property (nonatomic, weak) IBOutlet UILabel *hideCommentDescLabel;
@property (nonatomic, weak) IBOutlet UITableView *commentTableView;

@end

static void * kCommentsKeyValueObservingContext = &kCommentsKeyValueObservingContext;

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Labels
    NSTextAttachment *attachment1 = [[NSTextAttachment alloc] init];
    attachment1.image = [UIImage imageNamed:@"down_arrow.png"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment1];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"Hide Comments  "];
    [myString appendAttributedString:attachmentString];
    self.hideCommentLabel.attributedText = myString;
    
    NSTextAttachment *attachment2 = [[NSTextAttachment alloc] init];
    attachment2.image = [UIImage imageNamed:@"chat_icon.png"];
    attachmentString = [NSAttributedString attributedStringWithAttachment:attachment2];
    [myString setAttributedString:[[NSAttributedString alloc] initWithString:@"Everyone can view these comments. Use "]];
    [myString appendAttributedString:attachmentString];
    [myString appendAttributedString:[[NSAttributedString alloc] initWithString:@" for the personal information."]];
    self.hideCommentDescLabel.attributedText = myString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
    
    [self.inputTextView addObserver:self
                         forKeyPath:NSStringFromSelector(@selector(contentSize))
                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context:kCommentsKeyValueObservingContext];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove observers
    @try {
        [self.inputTextView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(contentSize))
                             context:kCommentsKeyValueObservingContext];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardDidHideNotification" object:nil];

    }
    @catch (NSException *__unused exception) { }
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
//                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:iUser.objectId
//                                                         senderDisplayName:iName
//                                                                      date:[objects[i] valueForKey:@"createdAt"]
//                                                                      text:[objects[i] valueForKey:@"comment"]];
//                NSLog(@"message %@", message);
//                [self.comments addObject:message];
                //                [self.avatars addObject:[JSQMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"avatarDefault"] withDiameter:70]];
                
            }
            //            [self loadAvatars];
            [self.commentTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)loadAvatars {
    for (int i = 0; i < self.comments.count; i++) {
        PFUser *writer;
        PFFile *profileAvatar = [writer valueForKey:@"profileImage"];
        if (profileAvatar != nil) {
            [profileAvatar getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
//                    JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                    //                    [self.avatars setObject:avatarImage atIndexedSubscript:i];
                }
            }];
        }
    }
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - Event Handlers

- (IBAction)hideCommentDidTouch:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonDidTouch:(id)sender {
    NSLog(@"send Comment");
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kCommentsKeyValueObservingContext) {
        
        if (object == self.inputTextView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
//            [self jsq_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
//            [self jsq_updateCollectionViewInsets];
//            if (self.automaticallyScrollsToMostRecentMessage) {
//                [self scrollToBottomAnimated:NO];
//            }
        }
    }
}


#pragma mark - Keyboard Handler
- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    kbRect.size.height += self.inputView.frame.size.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.commentTableView.contentInset = contentInsets;
    self.commentTableView.scrollIndicatorInsets = contentInsets;
    
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbRect.size.height;
//    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
//        [self.contentScrollView scrollRectToVisible:self.activeField.frame animated:YES];
//    }
}

- (void) keyboardDidHide:(NSNotification *)note {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.commentTableView.contentInset = contentInsets;
    self.commentTableView.scrollIndicatorInsets = contentInsets;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
