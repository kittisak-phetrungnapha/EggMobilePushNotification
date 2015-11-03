//
//  EggMobilePushNotificationAppDelegate.m
//  EggMobilePushNotification
//
//  Created by Kittisak Phetrungnapha on 10/29/2015.
//  Copyright (c) 2015 Kittisak Phetrungnapha. All rights reserved.
//

#import "EggMobilePushNotificationAppDelegate.h"

@interface EggMobilePushNotificationAppDelegate() <EggMobilePushNotificationManagerDelegate>

@end

@implementation EggMobilePushNotificationAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [EggMobilePushNotificationManager sharedInstance].delegate = self;
    [EggMobilePushNotificationManager sharedInstance].isDebug = YES; // Default debug is NO.
    [EggMobilePushNotificationManager sharedInstance].deviceToken = @"b809e416b12e31276186f34d490651ef1ae9b7d9c04a8d1bb03f7fa2abd8dd76";
    [EggMobilePushNotificationManager sharedInstance].app_id = @"2";
//    [[EggMobilePushNotificationManager sharedInstance] subscribeForRefId:@"ref_id_test" pushAlert:PushAlertTypeAlert pushSound:PushSoundTypeSound pushBadge:PushBadgeTypeBadge];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - EggMobilePushNotificationManager Delegate
- (void)didSubscribeSuccess {
    
}

- (void)didSubscribeFailWithErrorMessage:(NSString *)error_msg {
    
}

- (void)didUnsubscribeSuccess {
    
}

- (void)didUnsubscribeFailWithErrorMessage:(NSString *)error_msg {
    
}

- (void)didAcceptNotificationSuccess {
    
}

- (void)didAcceptNotificationFailWithErrorMessage:(NSString *)error_msg {
    
}

@end
