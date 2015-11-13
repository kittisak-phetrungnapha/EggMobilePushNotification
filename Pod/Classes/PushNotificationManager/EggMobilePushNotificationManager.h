//
//  EggMobilePushNotificationManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 10/29/2558 BE.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Enum
typedef enum {
    PushAlertTypeNone = 0,
    PushAlertTypeAlert = 1
} PushAlertType;

typedef enum {
    PushSoundTypeNone = 0,
    PushSoundTypeSound = 1
} PushSoundType;

typedef enum {
    PushBadgeTypeNone = 0,
    PushBadgeTypeBadge = 1
} PushBadgeType;

@interface EggMobilePushNotificationManager : NSObject

@property (nonatomic, strong) NSString *app_id;
@property (nonatomic) BOOL isDebug;

/**
 EggMobilePushNotificationManager's Singleton method
 */
+ (EggMobilePushNotificationManager *)sharedInstance;

// Register remote notification with Apple.
+ (void)registerRemoteNotification;

// Get clean device token.
- (void)setCleanDeviceTokenForData:(NSData *)tokenData;

// Subscribe
- (void)subscribeOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;

// Unsubscribe
- (void)unsubscribeOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;

// Accept notification
- (void)acceptNotificationForNotiRef:(NSString *)noti_ref onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;

// Setting
- (void)setTurnOnSound:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;
- (void)setTurnOnBadge:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;
- (void)setTurnOnNotification:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;

@end
