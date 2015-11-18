//
//  EggMobilePushNotificationManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 10/29/2558 BE.
//
//

#import "EggMobilePushNotificationManager.h"
#import "EggMobilePushNotificationNSUserDefaultsManager.h"
#import "TaskManager.h"
#import "ResponseObject.h"
#import "ConnectionManager.h"

// API
NSString *const MAIN_API_ANC            = @"http://api-truepush.eggdigital.com/api";
NSString *const OTHER_API_ANC           = @"http://api-anc.eggdigital.com";
#define API_SUBSCRIPTION                [NSString stringWithFormat:@"%@/subscription/ios", MAIN_API_ANC]
#define API_UNSUBSCRIPTION              [NSString stringWithFormat:@"%@/unsubscription/ios", MAIN_API_ANC]
#define API_ACCEPT_NOTIFICATION         [NSString stringWithFormat:@"%@/notificationlog/acceptNotification", OTHER_API_ANC]
NSString *const GET_MSISDN_API          = @"http://www3.truecorp.co.th/api/services/get_header";

// Message
NSString *const NSLogPrefix             = @"EggMobilePushNotification log:";
NSString *const DefaultErrorMsg         = @"The unknown error is occured.";
NSString *const GET_MSISDN_FAIL         = @"Only Truemove mobile network.";
NSString *const NoConnection            = @"The Internet connection appears to be offline.";

@interface EggMobilePushNotificationManager ()

@property (nonatomic, strong) NSString *deviceToken;

@end

@implementation EggMobilePushNotificationManager

#pragma mark - Initialization
+ (EggMobilePushNotificationManager *)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Set default value.
        self.isDebug = NO;
        self.deviceToken = @"";
        self.app_id = @"";
        
        if (![EggMobilePushNotificationNSUserDefaultsManager getNotFirstLaunch]) {
            [EggMobilePushNotificationNSUserDefaultsManager setNotificationState:YES];
            [EggMobilePushNotificationNSUserDefaultsManager setSoundState:YES];
            [EggMobilePushNotificationNSUserDefaultsManager setBadgeState:YES];
            
            [EggMobilePushNotificationNSUserDefaultsManager setNotFirstLaunch:YES];
        }
    }
    return self;
}

#pragma mark - Static
+ (void)registerRemoteNotification {
    UIApplication *application = [UIApplication sharedApplication];
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8+ Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

#pragma mark - Setter
- (void)setCleanDeviceTokenForData:(NSData *)tokenData {
    NSString *token = [[tokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (self.isDebug) {
        NSLog(@"%@ Device Token = %@", NSLogPrefix, token);
    }
    
    self.deviceToken = token;
}

#pragma mark - Subscribe
- (void)subscribeOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *))onFailure {
    [self subscribeForPushAlert:[EggMobilePushNotificationNSUserDefaultsManager getNotificationState] pushSound:[EggMobilePushNotificationNSUserDefaultsManager getSoundState] pushBadge:[EggMobilePushNotificationNSUserDefaultsManager getBadgeState] onSuccess:^{
        
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)subscribeForPushAlert:(PushAlertType)push_alert pushSound:(PushSoundType)push_sound pushBadge:(PushBadgeType)push_badge onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure {
    
    // Check network status before perform task.
    EPNetworkStatus networkStatus = [ConnectionManager checkNetworkStatus];
    switch (networkStatus) {
        case EPReachableViaWiFi: // Wifi
        {
            // Use msisdn from local cache for being the ref id.
            NSString *msisdn = [EggMobilePushNotificationNSUserDefaultsManager getMsisdn];
            if (msisdn == nil) { // Ignore subscribe
                if (self.isDebug) {
                    NSLog(@"%@ %@", NSLogPrefix, GET_MSISDN_FAIL);
                }
                
                onFailure(GET_MSISDN_FAIL);
            }
            else {
                [self performSubscribeTaskForMsisdn:msisdn pushAlert:push_alert pushSound:push_sound pushBadge:push_badge onSuccess:^{
                    onSuccess();
                } onFailure:^(NSString *error_msg) {
                    onFailure(error_msg);
                }];
            }
            
            break ;
        }
            
        case EPReachableViaWWAN: // Cellular
        {
            [self getMsisdnOnSuccess:^(NSString *msisdn) {
                [self performSubscribeTaskForMsisdn:msisdn pushAlert:push_alert pushSound:push_sound pushBadge:push_badge onSuccess:^{
                    onSuccess();
                } onFailure:^(NSString *error_msg) {
                    onFailure(error_msg);
                }];
                
            } onFailure:^(NSString *error_msg) {
                onFailure(error_msg);
            }];
            
            break ;
        }
            
        default: onFailure(NoConnection);
    }
}

- (ResponseObject *)parseDataForSubscribeWithDict:(NSDictionary *)dict {
    ResponseObject *ro = [[ResponseObject alloc] init];
    
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 0) { // Subscribe success
            if (self.isDebug) {
                NSLog(@"%@ Subscribe success", NSLogPrefix);
            }
            
            ro.isSuccess = YES;
            ro.error_msg = @"";
        }
        else { // Something went wrong. So, get error msg from API.
            NSString *error_msg = [[dict objectForKey:@"error"] objectForKey:@"msg"];
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, error_msg);
            }
            
            ro.isSuccess = NO;
            ro.error_msg = error_msg;
        }
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
        }
        
        ro.isSuccess = NO;
        ro.error_msg = DefaultErrorMsg;
    }
    
    return ro;
}

- (void)performSubscribeTaskForMsisdn:(NSString *)msisdn pushAlert:(PushAlertType)pushAlert pushSound:(PushSoundType)pushSound pushBadge:(PushBadgeType)pushBadge onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:API_SUBSCRIPTION];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"POST"];
    
    // Add parameters
    UIDevice *device = [UIDevice currentDevice];
    NSString *postString = [NSString stringWithFormat:@"device_token=%@&device_identifier=%@&device_version=%@&app_id=%@&app_version=%@&device_model=%@&msisdn=%@&push_alert=%d&push_sound=%d&push_badge=%d&app_pkg=%@", self.deviceToken, device.identifierForVendor.UUIDString, device.systemVersion, self.app_id, [self currentVersion], device.localizedModel, msisdn, pushAlert, pushSound, pushBadge, [self bundleId]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Create task for download.
    TaskManager *task = [[TaskManager alloc] initWithRequest:request isDebug:self.isDebug];
    [task performTaskWithCompletionHandlerOnSuccess:^(NSDictionary *responseDict) {
        
        // Parse data
        ResponseObject *ro = [self parseDataForSubscribeWithDict:responseDict];
        if (ro.isSuccess) {
            onSuccess();
        }
        else {
            onFailure(ro.error_msg);
        }
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)getMsisdnOnSuccess:(void (^)(NSString *msisdn))onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:GET_MSISDN_API];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"GET"];
    
    // Create task for download.
    TaskManager *task = [[TaskManager alloc] initWithRequest:request isDebug:self.isDebug];
    [task performTaskWithCompletionHandlerOnSuccess:^(NSDictionary *responseDict) {
        
        @try {
            // Parse data
            int status_code = [[[responseDict objectForKey:@"header"] objectForKey:@"code"] intValue];
            if (status_code == 200) {
                // Save msisdn
                NSString *msisdn = [[responseDict objectForKey:@"data"] objectForKey:@"msisdn"];
                if (!msisdn || [@"" isEqualToString:msisdn]) {
                    onFailure(GET_MSISDN_FAIL);
                }
                else {
                    if (self.isDebug) {
                        NSLog(@"%@ Get Msisdn success = %@", NSLogPrefix, msisdn);
                    }
                    
                    [EggMobilePushNotificationNSUserDefaultsManager setMsisdn:msisdn];
                    onSuccess(msisdn);
                }
            }
            else { // Something went wrong.
                if (self.isDebug) {
                    NSLog(@"%@ Error = %@", NSLogPrefix, GET_MSISDN_FAIL);
                }
                
                onFailure(GET_MSISDN_FAIL);
            }
        }
        @catch (NSException *exception) {
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
            }
            
            onFailure(DefaultErrorMsg);
        }
        
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

#pragma mark - Setting Notification
- (void)setTurnOnNotification:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    [self subscribeForPushAlert:isOn pushSound:[EggMobilePushNotificationNSUserDefaultsManager getSoundState] pushBadge:[EggMobilePushNotificationNSUserDefaultsManager getBadgeState] onSuccess:^{
        
        [EggMobilePushNotificationNSUserDefaultsManager setNotificationState:isOn];
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)setTurnOnSound:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    [self subscribeForPushAlert:[EggMobilePushNotificationNSUserDefaultsManager getNotificationState] pushSound:isOn pushBadge:[EggMobilePushNotificationNSUserDefaultsManager getBadgeState] onSuccess:^{
        
        [EggMobilePushNotificationNSUserDefaultsManager setSoundState:isOn];
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)setTurnOnBadge:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    [self subscribeForPushAlert:[EggMobilePushNotificationNSUserDefaultsManager getNotificationState] pushSound:[EggMobilePushNotificationNSUserDefaultsManager getSoundState] pushBadge:isOn onSuccess:^{
        
        [EggMobilePushNotificationNSUserDefaultsManager setBadgeState:isOn];
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

#pragma mark - Unsubscribe
- (void)unsubscribeOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure {
    
    // Get msisdn
    NSString *msisdn = [EggMobilePushNotificationNSUserDefaultsManager getMsisdn] ?: @"";
    
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:API_UNSUBSCRIPTION];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"POST"];
    
    // Add parameters
    UIDevice *device = [UIDevice currentDevice];
    NSString *postString = [NSString stringWithFormat:@"device_identifier=%@&app_id=%@&msisdn=%@", device.identifierForVendor.UUIDString, self.app_id, msisdn];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Create task for download.
    TaskManager *task = [[TaskManager alloc] initWithRequest:request isDebug:self.isDebug];
    [task performTaskWithCompletionHandlerOnSuccess:^(NSDictionary *responseDict) {
        
        // Parse data
        ResponseObject *ro = [self parseDataForUnsubscribeWithDict:responseDict];
        if (ro.isSuccess) {
            onSuccess();
        }
        else {
            onFailure(ro.error_msg);
        }
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (ResponseObject *)parseDataForUnsubscribeWithDict:(NSDictionary *)dict {
    ResponseObject *ro = [[ResponseObject alloc] init];
    
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 0) { // Unsubscribe success
            if (self.isDebug) {
                NSLog(@"%@ Unsubscribe success", NSLogPrefix);
            }
            
            [EggMobilePushNotificationNSUserDefaultsManager setMsisdn:nil];
            
            ro.isSuccess = YES;
            ro.error_msg = @"";
        }
        else { // Something went wrong. So, get error msg from API.
            NSString *error_msg = [[dict objectForKey:@"error"] objectForKey:@"msg"];
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, error_msg);
            }
            
            ro.isSuccess = NO;
            ro.error_msg = error_msg;
        }
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
        }
        
        ro.isSuccess = NO;
        ro.error_msg = DefaultErrorMsg;
    }
    
    return ro;
}

#pragma mark - Accept notification log
- (void)acceptNotificationForNotiRef:(NSString *)noti_ref onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure {
    // Check noti_ref
    if (noti_ref == nil) {
        noti_ref = @"";
    }
    
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:API_ACCEPT_NOTIFICATION];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"POST"];
    
    // Add parameters
    UIDevice *device = [UIDevice currentDevice];
    NSString *postString = [NSString stringWithFormat:@"device_identifier=%@&noti_ref=%@", device.identifierForVendor.UUIDString, noti_ref];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Create task for download.
    TaskManager *task = [[TaskManager alloc] initWithRequest:request isDebug:self.isDebug];
    [task performTaskWithCompletionHandlerOnSuccess:^(NSDictionary *responseDict) {
       
        // Parse data
        ResponseObject *ro = [self parseDataForAcceptNotificationWithDict:responseDict];
        if (ro.isSuccess) {
            onSuccess();
        }
        else {
            onFailure(ro.error_msg);
        }
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (ResponseObject *)parseDataForAcceptNotificationWithDict:(NSDictionary *)dict {
    ResponseObject *ro = [[ResponseObject alloc] init];
    
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 200) { // Accept notification success
            if (self.isDebug) {
                NSLog(@"%@ Accept notification success", NSLogPrefix);
            }
            
            ro.isSuccess = YES;
            ro.error_msg = @"";
        }
        else { // Something went wrong. So, get error msg from API.
            NSString *error_msg = [[dict objectForKey:@"error"] objectForKey:@"msg"];
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, error_msg);
            }
            
            ro.isSuccess = NO;
            ro.error_msg = error_msg;
        }
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
        }
        
        ro.isSuccess = NO;
        ro.error_msg = DefaultErrorMsg;
    }
    
    return ro;
}

#pragma mark - NSBundle Strings
- (NSString *)currentVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)bundleId {
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
