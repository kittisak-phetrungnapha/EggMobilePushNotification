//
//  EggMobilePushNotificationNSUserDefaultsManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/4/2558 BE.
//
//

#import "EggMobilePushNotificationNSUserDefaultsManager.h"

// Key
NSString *const EggPushNotificationDeviceTokenKey   = @"EggPushNotificationDeviceTokenKey";
NSString *const EggPushNotificationMsisdnKey        = @"EggPushNotificationMsisdnKey";
NSString *const EggPushNotificationSubscribedKey    = @"EggPushNotificationSubscribedKey";

@implementation EggMobilePushNotificationNSUserDefaultsManager

#pragma mark - Public
+ (NSString *)getDeviceToken {
    return [self getStringForKey:EggPushNotificationDeviceTokenKey];
}

+ (void)setDeviceToken:(NSString *)device_token {
    [self setString:device_token forKey:EggPushNotificationDeviceTokenKey];
}

+ (NSString *)getMsisdn {
    return [self getStringForKey:EggPushNotificationMsisdnKey];
}

+ (void)setMsisdn:(NSString *)msisdn {
    [self setString:msisdn forKey:EggPushNotificationMsisdnKey];
}

+ (BOOL)getSubscribed {
    return [self getBoolForKey:EggPushNotificationSubscribedKey];
}

+ (void)setSubscribed:(BOOL)boolean {
    [self setBool:boolean forKey:EggPushNotificationSubscribedKey];
}

#pragma mark - NSUserDefaults getter and setter
+ (void)setString:(NSString *)str forKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:str forKey:key];
    [ud synchronize];
}

+ (NSString *)getStringForKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:key];
}

+ (void)setBool:(BOOL)boolean forKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:boolean forKey:key];
    [ud synchronize];
}

+ (BOOL)getBoolForKey:(NSString *)key {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:key];
}

@end
