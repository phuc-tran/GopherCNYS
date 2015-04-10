//
//  CommentViewController.m
//  GopherCNYS
//
//  Created by Vu Tiet on 4/9/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentTableViewCell.h"
#import "JSQMessagesAvatarImageFactory.h"
#import <Parse/Parse.h>

@interface CommentViewController ()

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *avatars;
//@property (nonatomic, weak) IBOutlet UIView *inputView;
//@property (nonatomic, weak) IBOutlet UIView *inputBorderView;
//@property (nonatomic, weak) IBOutlet UITextView *inputTextView;
@property (nonatomic, weak) IBOutlet UILabel *hideCommentLabel;
@property (nonatomic, weak) IBOutlet UILabel *hideCommentDescLabel;
@property (nonatomic, weak) IBOutlet UITableView *commentTableView;
@property (nonatomic, weak) IBOutlet THChatInput *inputView;

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
    
    // Comment table
    [self.commentTableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCellIdentifier"];
    
    // initialize array comments
    self.comments = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];

    [self loadComments];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove observers
    @try {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardDidHideNotification" object:nil];

    }
    @catch (NSException *__unused exception) { }
}

- (void)loadComments {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"forProductId" equalTo:self.productId];
    [query includeKey:@"writer"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            self.comments = [NSMutableArray arrayWithArray:objects];
            [self.commentTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float cellHeight = 104; // initial height
    
    // Create cell only once
    static CommentTableViewCell *commentCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCellIdentifier"];
    });
    NSString *commentText = [self.comments[indexPath.row] valueForKey:@"comment"];
    CGSize commentTextSize = [commentText boundingRectWithSize:CGSizeMake(CGRectGetWidth(commentCell.descLabel.frame), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                                                                   NSFontAttributeName : commentCell.descLabel.font
                                                                                                                                                                   } context:nil].size;
    
    commentTextSize.height += 25 + 25; // top and bottom spaces
    if (commentTextSize.height > cellHeight) {
        cellHeight = commentTextSize.height;
    }
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCellIdentifier" forIndexPath:indexPath];

    // Name
    PFUser *iUser = [[self.comments objectAtIndex:indexPath.row] valueForKey:@"writer"];
    NSString *iName = [iUser valueForKey:@"name"];
    if (iName == nil) {
        iName = iUser.username;
    }
    cell.nameLabel.text = iName;
    
    // Comment
    cell.descLabel.text = [[self.comments objectAtIndex:indexPath.row] valueForKey:@"comment"];
    
    // Avatar
    PFFile *profileAvatar = [iUser valueForKey:@"profileImage"];
    if (profileAvatar != nil) {
        [profileAvatar getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.avatar.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
            }
        }];
    }
    else {
        // load avatar with profileImageURL
        NSString *profileImageUrlStr = [iUser objectForKey:@"profileImageURL"];
        NSURL *imageURL = [NSURL URLWithString:profileImageUrlStr];
        if (imageURL) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:imageURL
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        cell.avatar.image = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:70];
                                    }
                                }];
        }
        else { // No avatar, load default one
            cell.avatar.image = [JSQMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"avatarDefault"] withDiameter:70];
        }
    }

    // Date
    // Calculate the days / mins / hours of the latest message
    // The maximum days is 7
    NSString *updatedStr = @"";
    NSDate *updated = [self.comments[indexPath.row] createdAt] ? [self.comments[indexPath.row] createdAt] : [NSDate date];
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
    
    return cell;
}

#pragma mark - Event Handlers

- (IBAction)hideCommentDidTouch:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate hideComment];
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
}

- (void) keyboardDidHide:(NSNotification *)note {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.commentTableView.contentInset = contentInsets;
    self.commentTableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - THChatInput Delegate

- (void)chat:(THChatInput*)input sendWasPressed:(NSString*)text {
//    NSLog(@"text: %@", text);
    [self.inputView setText:@""];
    [self.inputView resignFirstResponder];
    
    // Create new comment
    PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
    newComment[@"comment"] = text;
    newComment[@"writer"] = [PFUser currentUser];
    newComment[@"forProductId"] = self.productId;

    [newComment saveInBackground];
    
    // Reload table view
    [self.comments addObject:newComment];
    [self.commentTableView reloadData];
    
    // scroll to bottom of the table
    NSIndexPath *bottomIndexPath = [NSIndexPath indexPathForRow:self.comments.count - 1 inSection:0];
    [self.commentTableView scrollToRowAtIndexPath:bottomIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
