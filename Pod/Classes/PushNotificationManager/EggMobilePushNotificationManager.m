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

// API
NSString *const MAIN_API_ANC            = @"http://api-anc.eggdigital.com";
#define API_SUBSCRIPTION                [NSString stringWithFormat:@"%@/subscription", MAIN_API_ANC]
#define API_UNSUBSCRIPTION              [NSString stringWithFormat:@"%@/subscription/unsubscribe", MAIN_API_ANC]
#define API_ACCEPT_NOTIFICATION         [NSString stringWithFormat:@"%@/notificationlog/acceptNotification", MAIN_API_ANC]
NSString *const GET_MSISDN_API          = @"http://www3.truecorp.co.th/api/services/get_header";

// Message
NSString *const NSLogPrefix             = @"EggMobilePushNotification log:";
NSString *const MissingDeviceToken      = @"Missing device token.";
NSString *const MissingAppId            = @"Missing app id.";
NSString *const MissingNotiRef          = @"Missing noti ref.";
NSString *const DefaultErrorMsg         = @"The unknown error is occured.";
NSString *const GET_MSISDN_FAIL         = @"Only Truemove mobile network.";

@interface EggMobilePushNotificationManager () <UIAlertViewDelegate>

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
        self.isDebug = NO;
        
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

#pragma mark - Public
- (void)setCleanDeviceTokenForData:(NSData *)tokenData {
    NSString *token = [[tokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (self.isDebug) {
        NSLog(@"%@ Device Token = %@", NSLogPrefix, token);
    }
    
    self.deviceToken = token;
    
    // Save clean device token
//    [EggMobilePushNotificationNSUserDefaultsManager setDeviceToken:token];
}

- (void)subscribeOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *))onFailure {
    [self subscribeForPushAlert:PushAlertTypeAlert pushSound:PushSoundTypeSound pushBadge:PushBadgeTypeBadge onSuccess:^{
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)subscribeForPushAlert:(PushAlertType)push_alert pushSound:(PushSoundType)push_sound pushBadge:(PushBadgeType)push_badge onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure {
    // Check device token.
    if (!self.deviceToken) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingDeviceToken);
        }
        
        onFailure(MissingDeviceToken);
        
        return ;
    }
    
    // Check app id.
    if (!self.app_id) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingAppId);
        }
        
        onFailure(MissingAppId);
        
        return ;
    }
    
    [self getMsisdnOnSuccess:^(NSString *msisdn) {
        // Initialize apiURL, and create request object.
        NSURL *apiURL = [NSURL URLWithString:API_SUBSCRIPTION];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        
        // Add parameters
        UIDevice *device = [UIDevice currentDevice];
        NSString *postString = [NSString stringWithFormat:@"device_token=%@&device_identifier=%@&device_type=ios&device_version=%@&app_id=%@&app_version=%@&device_model=%@&ref_id=%@&push_alert=%d&push_sound=%d&push_badge=%d", self.deviceToken, device.identifierForVendor.UUIDString, device.systemVersion, self.app_id, [self currentVersion], device.localizedModel, msisdn, push_alert, push_sound, push_badge];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (self.isDebug) {
            NSLog(@"%@ Url request = %@", NSLogPrefix, request.URL.absoluteString);
            NSLog(@"%@ Parameter = %@", NSLogPrefix, postString);
            NSLog(@"%@ Method = %@", NSLogPrefix, request.HTTPMethod);
        }
        
        // Create task for download.
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    if (error == nil && data.length > 0) { // Success
                        NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        if (self.isDebug) {
                            NSLog(@"%@ Subscribe JSON result = %@", NSLogPrefix, appData);
                        }
                        
                        // Check response from server.
                        if (appData == nil) { // Invalid data
                            if (self.isDebug) {
                                NSLog(@"%@ Error = %@", NSLogPrefix, DefaultErrorMsg);
                            }
                            onFailure(DefaultErrorMsg);
                            
                            return ;
                        }
                        
                        // Parse data
                        ResponseObject *ro = [self parseDataForSubscribeWithDict:appData];
                        if (ro.isSuccess) {
                            onSuccess();
                        }
                        else {
                            onFailure(ro.error_msg);
                        }
                    }
                    else { // Fail
                        if (self.isDebug) {
                            NSLog(@"%@ Error = %@", NSLogPrefix, [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                        }
                        
                        onFailure([error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    }
                }
                @catch (NSException *exception) {
                    if (self.isDebug) {
                        NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
                    }
                    
                    onFailure(DefaultErrorMsg);
                }
            });
        }];
        // Start task
        [task resume];
        
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)unsubscribeOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure {
    // Check app id.
    if (!self.app_id) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingAppId);
        }
        
        onFailure(MissingAppId);
        
        return ;
    }
    
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:API_UNSUBSCRIPTION];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"POST"];
    
    // Add parameters
    UIDevice *device = [UIDevice currentDevice];
    NSString *postString = [NSString stringWithFormat:@"device_identifier=%@&device_type=ios&app_id=%@", device.identifierForVendor.UUIDString, self.app_id];
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

- (void)acceptNotificationForNotiRef:(NSString *)noti_ref onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure {
    // Check noti_ref
    if (!noti_ref) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, MissingNotiRef);
        }
        
        onFailure(MissingNotiRef);
        
        return ;
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

- (void)showAlertViewForDict:(NSDictionary *)dict viewControllerToPresent:(UIViewController *)vc tag:(NSInteger)tag {
    if ([UIAlertController class]) {
        // use UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:@"Message" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertFirstAction = [UIAlertAction actionWithTitle:@"First" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:alertFirstAction];
        
        UIAlertAction *alertSecondAction = [UIAlertAction actionWithTitle:@"Second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:alertSecondAction];
        
//        UIAlertAction *alertThirdAction = [UIAlertAction actionWithTitle:@"Third" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        [alertController addAction:alertThirdAction];
        
        // Show alert controller
        [vc presentViewController:alertController animated:YES completion:nil];
    } else {
        // use UIAlertView
        UIAlertView *alertView = [[UIAlertView alloc] init];
        alertView.title = @"Title";
        alertView.message = @"Message";
        alertView.delegate = self;
        alertView.tag = tag;
        
        [alertView addButtonWithTitle:@"First"];
        [alertView setCancelButtonIndex:0];
        
        [alertView addButtonWithTitle:@"Second"];
        
//        [alertView addButtonWithTitle:@"Third"];
        
        // Show alert view
        [alertView show];
    }
}

#pragma mark - Setting Notification
- (void)setTurnOnNotification:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    [self updateNotificationConfigForPushAlert:isOn pushSound:[EggMobilePushNotificationNSUserDefaultsManager getSoundState] pushBadge:[EggMobilePushNotificationNSUserDefaultsManager getBadgeState] onSuccess:^{
        
        [EggMobilePushNotificationNSUserDefaultsManager setNotificationState:isOn];
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)setTurnOnSound:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    [self updateNotificationConfigForPushAlert:[EggMobilePushNotificationNSUserDefaultsManager getNotificationState] pushSound:isOn pushBadge:[EggMobilePushNotificationNSUserDefaultsManager getBadgeState] onSuccess:^{
        
        [EggMobilePushNotificationNSUserDefaultsManager setSoundState:isOn];
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

- (void)setTurnOnBadge:(BOOL)isOn onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    [self updateNotificationConfigForPushAlert:[EggMobilePushNotificationNSUserDefaultsManager getNotificationState] pushSound:[EggMobilePushNotificationNSUserDefaultsManager getSoundState] pushBadge:isOn onSuccess:^{
        
        [EggMobilePushNotificationNSUserDefaultsManager setBadgeState:isOn];
        onSuccess();
    } onFailure:^(NSString *error_msg) {
        onFailure(error_msg);
    }];
}

#pragma mark - Private
- (void)getMsisdnOnSuccess:(void (^)(NSString *msisdn))onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:GET_MSISDN_API];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"GET"];
    
    if (self.isDebug) {
        NSLog(@"%@ Url request = %@", NSLogPrefix, request.URL.absoluteString);
        NSLog(@"%@ Method = %@", NSLogPrefix, request.HTTPMethod);
    }
    
    // Create task for download.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                if (error == nil && data.length > 0) { // Success
                    NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if (self.isDebug) {
                        NSLog(@"%@ Get Msisdn JSON result = %@", NSLogPrefix, appData);
                    }
                    
                    // Check response from server.
                    if (appData == nil) { // Invalid data
                        if (self.isDebug) {
                            NSLog(@"%@ Error = %@", NSLogPrefix, DefaultErrorMsg);
                        }
                        onFailure(DefaultErrorMsg);
                        
                        return ;
                    }
                    
                    // Parse data
                    int status_code = [[[appData objectForKey:@"header"] objectForKey:@"code"] intValue];
                    if (status_code == 200) {
                        if (self.isDebug) {
                            NSLog(@"%@ Get Msisdn success", NSLogPrefix);
                        }
                        
                        NSString *msisdn = [[appData objectForKey:@"data"] objectForKey:@"msisdn"];
                        
                        // Save msisdn
                        [EggMobilePushNotificationNSUserDefaultsManager setMsisdn:msisdn];
                        
                        onSuccess(msisdn);
                    }
                    else { // Something went wrong.
                        if (self.isDebug) {
                            NSLog(@"%@ Error = %@", NSLogPrefix, GET_MSISDN_FAIL);
                        }
                        
                        onFailure(GET_MSISDN_FAIL);
                    }
                }
                else { // Fail
                    if (self.isDebug) {
                        NSLog(@"%@ Error = %@", NSLogPrefix, [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    }
                    
                    onFailure([error.userInfo objectForKey:@"NSLocalizedDescription"]);
                }
            }
            @catch (NSException *exception) {
                if (self.isDebug) {
                    NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
                }
                
                onFailure(DefaultErrorMsg);
            }
        });
    }];
    // Start task
    [task resume];
}

- (void)updateNotificationConfigForPushAlert:(PushAlertType)push_alert pushSound:(PushSoundType)push_sound pushBadge:(PushBadgeType)push_badge onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    // Check device token.
    if (!self.deviceToken) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingDeviceToken);
        }
        
        onFailure(MissingDeviceToken);
        
        return ;
    }
    
    // Check app id.
    if (!self.app_id) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingAppId);
        }
        
        onFailure(MissingAppId);
        
        return ;
    }
    
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:API_SUBSCRIPTION];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"POST"];
    
    // Add parameters
    UIDevice *device = [UIDevice currentDevice];
    NSString *msisdn = [EggMobilePushNotificationNSUserDefaultsManager getMsisdn] ?: @"";
    
    NSString *postString = [NSString stringWithFormat:@"device_token=%@&device_identifier=%@&device_type=ios&device_version=%@&app_id=%@&app_version=%@&device_model=%@&ref_id=%@&push_alert=%d&push_sound=%d&push_badge=%d", self.deviceToken, device.identifierForVendor.UUIDString, device.systemVersion, self.app_id, [self currentVersion], device.localizedModel, msisdn, push_alert, push_sound, push_badge];
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

- (ResponseObject *)parseDataForSubscribeWithDict:(NSDictionary *)dict {
    ResponseObject *ro = [[ResponseObject alloc] init];
    
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 200) { // Subscribe success
            // Save subscribed success already.
//            [EggMobilePushNotificationNSUserDefaultsManager setSubscribed:YES];
            
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

- (ResponseObject *)parseDataForUnsubscribeWithDict:(NSDictionary *)dict {
    ResponseObject *ro = [[ResponseObject alloc] init];
    
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 200) { // Unsubscribe success
            if (self.isDebug) {
                NSLog(@"%@ Unsubscribe success", NSLogPrefix);
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
- (NSString *)currentVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    }
    else if (buttonIndex == 1) {
        
    }
    else if (buttonIndex == 2) {
        
    }
}

@end
