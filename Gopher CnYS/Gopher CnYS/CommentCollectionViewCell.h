//
//  CommentCollectionViewCell.h
//  GopherCNYS
//
//  Created by Vu Tiet on 4/5/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "JSQMessagesCollectionViewCell.h"

@interface CommentCollectionViewCell : JSQMessagesCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *writerLabel;

@end
