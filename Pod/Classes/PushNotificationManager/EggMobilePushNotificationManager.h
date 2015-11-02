//
//  EggMobilePushNotificationManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 10/29/2558 BE.
//
//

#import <Foundation/Foundation.h>

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

@protocol EggMobilePushNotificationManagerDelegate <NSObject>

@optional
- (void)didSubscribeSuccess;                                            // Delegate when subscribe success.
- (void)didSubscribeFailWithErrorMessage:(NSString *)error_msg;         // Delegate when subscribe fail.
- (void)didUnsubscribeSuccess;                                          // Delegate when unsubscribe success.
- (void)didUnsubscribeFailWithErrorMessage:(NSString *)error_msg;       // Delegate when unsubscribe fail.
- (void)didAcceptNotificationSuccess;                                   // Delegate when accept success.
- (void)didAcceptNotificationFailWithErrorMessage:(NSString *)error_msg; // Delegate when accept fail.

@end

@interface EggMobilePushNotificationManager : NSObject

@property (nonatomic, weak) id<EggMobilePushNotificationManagerDelegate> delegate;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *app_id;
@property (nonatomic) BOOL isDebug;

/**
 EggMobilePushNotificationManager's Singleton method
 */
+ (EggMobilePushNotificationManager *)sharedInstance;

// Subscribe
- (void)subscribeForRefId:(NSString *)ref_id;
- (void)subscribeForRefId:(NSString *)ref_id pushAlert:(PushAlertType)push_alert pushSound:(PushSoundType)push_sound pushBadge:(PushBadgeType)push_badge;

// Unsubscribe
- (void)unsubscribe;

// Accept notification
- (void)acceptNotificationForNotiRef:(NSString *)noti_ref;

@end
