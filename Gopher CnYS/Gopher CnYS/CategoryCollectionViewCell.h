//
//  CategoryCollectionViewCell.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryCollectionViewCellDelegate <NSObject>
@optional
- (void)onCellSelect:(NSInteger)index;
@end

@interface CategoryCollectionViewCell : UICollectionViewCell
{
    
}

@property (nonatomic, assign) BOOL isSelected;

@property (weak, nonatomic) IBOutlet UILabel *categoryLable;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (assign, nonatomic) id<CategoryCollectionViewCellDelegate> delegate;
@property (unsafe_unretained, nonatomic) NSUInteger cellIndex;

- (void)update:(BOOL)selected;
- (IBAction)selected:(id)sender;

@end
