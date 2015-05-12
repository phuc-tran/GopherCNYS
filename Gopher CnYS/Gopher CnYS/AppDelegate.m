//
//  AppDelegate.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 12/24/14.
//  Copyright (c) 2014 cnys. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <GooglePlus/GooglePlus.h>
#import "ProductListViewController.h"


@interface AppDelegate ()
{
    CLLocationManager *locationManager;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"5ipBuTmdEryP29CFELzxMx2qXGzgndRPhG4ltAnc"
                  clientKey:@"JI5AkADSTQmssXVE4Y1o6T5lLDkZumXWUgH2MV2J"];
    
    //////////////////////////////////
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:64/255.0f green:222/255.0f blue:172/255.0f alpha:1.0f]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:20.0], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    [PFFacebookUtils initializeFacebook];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if (IS_OS_8_OR_LATER) {
       [self requestAlwaysAuthorization];
    }
    
    NSDictionary *remoteNotifDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotifDict) {
        // Receive notification from remote
//        NSLog(@"Receive notification from remote %@", remoteNotifDict);
        NSLog(@"post nsnotification when app launch");
        // Post notification after 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GopherBackgroundReceivePushNotificationFromParse" object:nil userInfo:remoteNotifDict];
        });
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"openURL || sourceApplication %@ || %@", url, sourceApplication);
    // Post notification after 2 seconds
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:url, @"openURL", sourceApplication, @"sourceApplication", nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GopherReceivePushBacklink" object:nil userInfo:dict];
    });
    
    if ([FBAppCall handleOpenURL:url
               sourceApplication:sourceApplication
                     withSession:[PFFacebookUtils session]]) {
        return YES;
    }
    
    if ([GPPURLHandler handleURL:url
               sourceApplication:sourceApplication
                      annotation:annotation]) {
        return YES;
    }
    
    
    return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken %@", [deviceToken description]);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog(@"get notification: %@", userInfo);
//    [PFPush handlePush:userInfo];
    
    // Handle these case:
    // 1. user sends private message
    // 2. admin sends notifications from Parse UI
    // 3. user comments on products
    // 4. user receives feedback on their sellers page
    // 5. user is being followed
    
    // Broadcasts receiving push notification event
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        // Open app from background
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GopherBackgroundReceivePushNotificationFromParse" object:nil userInfo:userInfo];
    }
    else {
        // App is in foreground
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GopherForegroundReceivePushNotificationFromParse" object:nil userInfo:userInfo];

    }
    
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status ==  kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" :   @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse  || status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startUpdatingLocation];
    }

}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    _currentLocation = newLocation;
    [locationManager stopUpdatingLocation];
}

@end
