//
//  EggMobilePushNotificationNSUserDefaultsManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/4/2558 BE.
//
//

#import <Foundation/Foundation.h>

@interface EggMobilePushNotificationNSUserDefaultsManager : NSObject

// Device Token
+ (NSString *)getDeviceToken;
+ (void)setDeviceToken:(NSString *)device_token;

// Msisdn
+ (NSString *)getMsisdn;
+ (void)setMsisdn:(NSString *)msisdn;

// Subscribed
+ (BOOL)getSubscribed;
+ (void)setSubscribed:(BOOL)boolean;

@end
