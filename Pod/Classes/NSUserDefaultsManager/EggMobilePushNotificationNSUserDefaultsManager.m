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
NSString *const EggPushNotificationNotificationKey  = @"EggPushNotificationNotificationKey";
NSString *const EggPushNotificationSoundKey         = @"EggPushNotificationSoundKey";
NSString *const EggPushNotificationBadgeKey         = @"EggPushNotificationBadgeKey";
NSString *const EggPushNotificationNotFirstLaunchKey   = @"EggPushNotificationNotFirstLaunchKey";

@implementation EggMobilePushNotificationNSUserDefaultsManager

#pragma mark - Public
+ (BOOL)getNotFirstLaunch {
    return [self getBoolForKey:EggPushNotificationNotFirstLaunchKey];
}

+ (void)setNotFirstLaunch:(BOOL)isNotFirstLaunch {
    [self setBool:isNotFirstLaunch forKey:EggPushNotificationNotFirstLaunchKey];
}

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

+ (void)setSubscribed:(BOOL)isSubscribe {
    [self setBool:isSubscribe forKey:EggPushNotificationSubscribedKey];
}

+ (BOOL)getNotificationState {
    return [self getBoolForKey:EggPushNotificationNotificationKey];
}

+ (void)setNotificationState:(BOOL)state {
    [self setBool:state forKey:EggPushNotificationNotificationKey];
}

+ (BOOL)getSoundState {
    return [self getBoolForKey:EggPushNotificationSoundKey];
}

+ (void)setSoundState:(BOOL)state {
    [self setBool:state forKey:EggPushNotificationSoundKey];
}

+ (BOOL)getBadgeState {
    return [self getBoolForKey:EggPushNotificationBadgeKey];
}

+ (void)setBadgeState:(BOOL)state {
    [self setBool:state forKey:EggPushNotificationBadgeKey];
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
