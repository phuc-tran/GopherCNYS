//
// ProductListTableFooterView.h
//
// @author Shiki
//

#import <UIKit/UIKit.h>


@interface ProductListTableFooterView : UIView {
    
  UIActivityIndicatorView *activityIndicator;
  UILabel *infoLabel;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;

@end
