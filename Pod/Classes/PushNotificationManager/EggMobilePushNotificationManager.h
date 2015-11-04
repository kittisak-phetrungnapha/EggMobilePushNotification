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
// ANC Push notification handler result delegate method
- (void)didSubscribeSuccess;
- (void)didSubscribeFailWithErrorMessage:(NSString *)error_msg;
- (void)didUnsubscribeSuccess;
- (void)didUnsubscribeFailWithErrorMessage:(NSString *)error_msg;
- (void)didAcceptNotificationSuccess;
- (void)didAcceptNotificationFailWithErrorMessage:(NSString *)error_msg;

// AlertView action delegate method
- (void)didClickFirstButtonForAlertViewTag:(NSInteger)tag;
- (void)didClickSecondButtonForAlertViewTag:(NSInteger)tag;
- (void)didClickThirdButtonForAlertViewTag:(NSInteger)tag;

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

// Register remote notification with Apple.
+ (void)registerRemoteNotification;

// Get clean device token.
- (void)setCleanDeviceTokenForData:(NSData *)tokenData;

// Subscribe
- (void)subscribeForRefId:(NSString *)ref_id pushAlert:(PushAlertType)push_alert pushSound:(PushSoundType)push_sound pushBadge:(PushBadgeType)push_badge;

// Unsubscribe
- (void)unsubscribe;

// Accept notification
- (void)acceptNotificationForNotiRef:(NSString *)noti_ref;

// Show native alert
- (void)showAlertViewForTitle:(NSString *)title message:(NSString *)message firstButtonTitle:(NSString *)firstButtonTitle secondButtonTitle:(NSString *)secondButtonTitle thirdButtonTitle:(NSString *)thirdButtonTitle viewControllerToPresent:(UIViewController *)vc tag:(NSInteger)tag;

@end
