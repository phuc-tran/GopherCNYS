//
//  AppDelegate.h
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 12/24/14.
//  Copyright (c) 2014 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CLLocation *currentLocation;;
@end

