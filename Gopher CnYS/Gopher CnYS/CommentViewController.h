//
//  CommentViewController.h
//  GopherCNYS
//
//  Created by Vu Tiet on 4/9/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "BaseViewController.h"
#import "THChatInput.h"

@protocol CommentViewControllerDelegate <NSObject>

-(void)hideComment;

@end

@interface CommentViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, THChatInputDelegate>

@property (nonatomic, strong) UIImage *userInfoImage;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, assign) id <CommentViewControllerDelegate> delegate;

@end
