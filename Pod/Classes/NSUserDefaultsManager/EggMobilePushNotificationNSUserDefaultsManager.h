//
//  EggMobilePushNotificationNSUserDefaultsManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/4/2558 BE.
//
//

#import <Foundation/Foundation.h>

@interface EggMobilePushNotificationNSUserDefaultsManager : NSObject

// Check first launch application.
+ (BOOL)getNotFirstLaunch;
+ (void)setNotFirstLaunch:(BOOL)isNotFirstLaunch;

// Device Token
+ (NSString *)getDeviceToken;
+ (void)setDeviceToken:(NSString *)device_token;

// Msisdn
+ (NSString *)getMsisdn;
+ (void)setMsisdn:(NSString *)msisdn;

// Subscribed
+ (BOOL)getSubscribed;
+ (void)setSubscribed:(BOOL)isSubscribe;

// Notification state
+ (BOOL)getNotificationState;
+ (void)setNotificationState:(BOOL)state;

// Sound state
+ (BOOL)getSoundState;
+ (void)setSoundState:(BOOL)state;

// Badge state
+ (BOOL)getBadgeState;
+ (void)setBadgeState:(BOOL)state;

@end
