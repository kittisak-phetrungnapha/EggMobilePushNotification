//
//  EggMobilePushNotificationManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 10/29/2558 BE.
//
//

#import "EggMobilePushNotificationManager.h"

// API
NSString *const MAIN_API_ANC            = @"http://api-anc.eggdigital.com";
#define API_SUBSCRIPTION                [NSString stringWithFormat:@"%@/subscription", MAIN_API_ANC]
#define API_UNSUBSCRIPTION              [NSString stringWithFormat:@"%@/subscription/unsubscribe", MAIN_API_ANC]
#define API_ACCEPT_NOTIFICATION         [NSString stringWithFormat:@"%@/notificationlog/acceptNotification", MAIN_API_ANC]

NSString *const NSLogPrefix             = @"EggMobilePushNotification log:";
NSString *const MissingDeviceToken      = @"Missing device token.";
NSString *const MissingAppId            = @"Missing app id.";
NSString *const MissingNotiRef          = @"Missing noti ref.";
NSString *const DefaultErrorMsg         = @"The unknown error is occured.";

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
    }
    return self;
}

#pragma mark - Public
- (void)subscribeForRefId:(NSString *)ref_id {
    [self subscribeForRefId:ref_id pushAlert:PushAlertTypeAlert pushSound:PushSoundTypeSound pushBadge:PushBadgeTypeBadge];
}

- (void)subscribeForRefId:(NSString *)ref_id pushAlert:(PushAlertType)push_alert pushSound:(PushSoundType)push_sound pushBadge:(PushBadgeType)push_badge {
    // Check device token.
    if (!self.deviceToken) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingDeviceToken);
        }
        
        if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
            [self.delegate didSubscribeFailWithErrorMessage:MissingDeviceToken];
        }
        
        return ;
    }
    
    // Check app id.
    if (!self.app_id) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingAppId);
        }
        
        if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
            [self.delegate didSubscribeFailWithErrorMessage:MissingAppId];
        }
        
        return ;
    }
    
    // Check ref id.
    if (!ref_id) {
        ref_id = @"";
    }
    
    // Initialize apiURL, and create request object.
    NSURL *apiURL = [NSURL URLWithString:API_SUBSCRIPTION];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"POST"];
    
    // Add parameters
    UIDevice *device = [UIDevice currentDevice];
    NSString *postString = [NSString stringWithFormat:@"device_token=%@&device_identifier=%@&device_type=ios&device_version=%@&app_id=%@&app_version=%@&device_model=%@&ref_id=%@&push_alert=%d&push_sound=%d&push_badge=%d", self.deviceToken, device.identifierForVendor.UUIDString, device.systemVersion, self.app_id, [self currentVersion], device.localizedModel, ref_id, push_alert, push_sound, push_badge];
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
                        if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
                            [self.delegate didSubscribeFailWithErrorMessage:DefaultErrorMsg];
                        }
                        
                        return ;
                    }
                    
                    // Parse data
                    [self parseDataForSubscribeWithDict:appData];
                }
                else { // Fail
                    if (self.isDebug) {
                        NSLog(@"%@ Error = %@", NSLogPrefix, [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
                        [self.delegate didSubscribeFailWithErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
                    }
                }
            }
            @catch (NSException *exception) {
                if (self.isDebug) {
                    NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
                }
                
                if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
                    [self.delegate didSubscribeFailWithErrorMessage:DefaultErrorMsg];
                }
            }
        });
    }];
    // Start task
    [task resume];
}

- (void)unsubscribe {
    // Check app id.
    if (!self.app_id) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefix, MissingAppId);
        }
        
        if ([self.delegate respondsToSelector:@selector(didUnsubscribeFailWithErrorMessage:)]) {
            [self.delegate didUnsubscribeFailWithErrorMessage:MissingAppId];
        }
        
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
                        NSLog(@"%@ Unsubscribe JSON result = %@", NSLogPrefix, appData);
                    }
                    
                    // Check response from server.
                    if (appData == nil) { // Invalid data
                        if (self.isDebug) {
                            NSLog(@"%@ Error = %@", NSLogPrefix, DefaultErrorMsg);
                        }
                        if ([self.delegate respondsToSelector:@selector(didUnsubscribeFailWithErrorMessage:)]) {
                            [self.delegate didUnsubscribeFailWithErrorMessage:DefaultErrorMsg];
                        }
                        
                        return ;
                    }
                    
                    // Parse data
                    [self parseDataForUnsubscribeWithDict:appData];
                }
                else { // Fail
                    if (self.isDebug) {
                        NSLog(@"%@ Error = %@", NSLogPrefix, [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(didUnsubscribeFailWithErrorMessage:)]) {
                        [self.delegate didUnsubscribeFailWithErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
                    }
                }
            }
            @catch (NSException *exception) {
                if (self.isDebug) {
                    NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
                }
                
                if ([self.delegate respondsToSelector:@selector(didUnsubscribeFailWithErrorMessage:)]) {
                    [self.delegate didUnsubscribeFailWithErrorMessage:DefaultErrorMsg];
                }
            }
        });
    }];
    // Start task
    [task resume];
}

- (void)acceptNotificationForNotiRef:(NSString *)noti_ref {
    // Check noti_ref
    if (!noti_ref) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, MissingNotiRef);
        }
        
        if ([self.delegate respondsToSelector:@selector(didAcceptNotificationFailWithErrorMessage:)]) {
            [self.delegate didAcceptNotificationFailWithErrorMessage:MissingNotiRef];
        }
        
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
                        NSLog(@"%@ Accept Notification JSON result = %@", NSLogPrefix, appData);
                    }
                    
                    // Check response from server.
                    if (appData == nil) { // Invalid data
                        if (self.isDebug) {
                            NSLog(@"%@ Error = %@", NSLogPrefix, DefaultErrorMsg);
                        }
                        if ([self.delegate respondsToSelector:@selector(didAcceptNotificationFailWithErrorMessage:)]) {
                            [self.delegate didAcceptNotificationFailWithErrorMessage:DefaultErrorMsg];
                        }
                        
                        return ;
                    }
                    
                    // Parse data
                    [self parseDataForAcceptNotificationWithDict:appData];
                }
                else { // Fail
                    if (self.isDebug) {
                        NSLog(@"%@ Error = %@", NSLogPrefix, [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(didAcceptNotificationFailWithErrorMessage:)]) {
                        [self.delegate didAcceptNotificationFailWithErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
                    }
                }
            }
            @catch (NSException *exception) {
                if (self.isDebug) {
                    NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
                }
                
                if ([self.delegate respondsToSelector:@selector(didAcceptNotificationFailWithErrorMessage:)]) {
                    [self.delegate didAcceptNotificationFailWithErrorMessage:DefaultErrorMsg];
                }
            }
        });
    }];
    // Start task
    [task resume];
}

- (void)showAlertViewForTitle:(NSString *)title message:(NSString *)message firstButtonTitle:(NSString *)firstButtonTitle secondButtonTitle:(NSString *)secondButtonTitle thirdButtonTitle:(NSString *)thirdButtonTitle viewControllerToPresent:(UIViewController *)vc tag:(NSInteger)tag {
    
    if ([UIAlertController class]) {
        // use UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Add button action if need.
        if (firstButtonTitle && ![@"" isEqualToString:firstButtonTitle]) {
            UIAlertAction *alertFirstAction = [UIAlertAction actionWithTitle:firstButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                if ([self.delegate respondsToSelector:@selector(didClickFirstButtonForAlertViewTag:)]) {
                    [self.delegate didClickFirstButtonForAlertViewTag:tag];
                }
            }];
            [alertController addAction:alertFirstAction];
        }
        
        if (secondButtonTitle && ![@"" isEqualToString:secondButtonTitle]) {
            UIAlertAction *alertSecondAction = [UIAlertAction actionWithTitle:secondButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if ([self.delegate respondsToSelector:@selector(didClickSecondButtonForAlertViewTag:)]) {
                    [self.delegate didClickSecondButtonForAlertViewTag:tag];
                }
            }];
            [alertController addAction:alertSecondAction];
        }
        
        if (thirdButtonTitle && ![@"" isEqualToString:thirdButtonTitle]) {
            UIAlertAction *alertThirdAction = [UIAlertAction actionWithTitle:thirdButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if ([self.delegate respondsToSelector:@selector(didClickThirdButtonForAlertViewTag:)]) {
                    [self.delegate didClickThirdButtonForAlertViewTag:tag];
                }
            }];
            [alertController addAction:alertThirdAction];
        }
        
        // Show alert controller
        [vc presentViewController:alertController animated:YES completion:nil];
    } else {
        // use UIAlertView
        UIAlertView *alertView = [[UIAlertView alloc] init];
        alertView.title = title;
        alertView.message = message;
        alertView.delegate = self;
        alertView.tag = tag;
        
        // Add button action if need.
        if (firstButtonTitle && ![@"" isEqualToString:firstButtonTitle]) {
            [alertView addButtonWithTitle:firstButtonTitle];
            [alertView setCancelButtonIndex:0];
        }
        
        if (secondButtonTitle && ![@"" isEqualToString:secondButtonTitle]) {
            [alertView addButtonWithTitle:secondButtonTitle];
        }
        
        if (thirdButtonTitle && ![@"" isEqualToString:thirdButtonTitle]) {
            [alertView addButtonWithTitle:thirdButtonTitle];
        }
        
        // Show alert view
        [alertView show];
    }
}

#pragma mark - Private
- (void)parseDataForSubscribeWithDict:(NSDictionary *)dict {
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 200) { // Subscribe success
            if (self.isDebug) {
                NSLog(@"%@ Subscribe success", NSLogPrefix);
            }
            
            if ([self.delegate respondsToSelector:@selector(didSubscribeSuccess)]) {
                [self.delegate didSubscribeSuccess];
            }
        }
        else { // Something went wrong. So, get error msg from API.
            NSString *error_msg = [[dict objectForKey:@"error"] objectForKey:@"msg"];
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, error_msg);
            }
            
            if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
                [self.delegate didSubscribeFailWithErrorMessage:error_msg];
            }
        }
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
        }
        
        if ([self.delegate respondsToSelector:@selector(didSubscribeFailWithErrorMessage:)]) {
            [self.delegate didSubscribeFailWithErrorMessage:DefaultErrorMsg];
        }
    }
}

- (void)parseDataForUnsubscribeWithDict:(NSDictionary *)dict {
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 200) { // Unsubscribe success
            if (self.isDebug) {
                NSLog(@"%@ Unsubscribe success", NSLogPrefix);
            }
            
            if ([self.delegate respondsToSelector:@selector(didUnsubscribeSuccess)]) {
                [self.delegate didUnsubscribeSuccess];
            }
        }
        else { // Something went wrong. So, get error msg from API.
            NSString *error_msg = [[dict objectForKey:@"error"] objectForKey:@"msg"];
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, error_msg);
            }
            
            if ([self.delegate respondsToSelector:@selector(didUnsubscribeFailWithErrorMessage:)]) {
                [self.delegate didUnsubscribeFailWithErrorMessage:error_msg];
            }
        }
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
        }
        
        if ([self.delegate respondsToSelector:@selector(didUnsubscribeFailWithErrorMessage:)]) {
            [self.delegate didUnsubscribeFailWithErrorMessage:DefaultErrorMsg];
        }
    }
}

- (void)parseDataForAcceptNotificationWithDict:(NSDictionary *)dict {
    @try {
        int status_code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
        if (status_code == 200) { // Accept notification success
            if (self.isDebug) {
                NSLog(@"%@ Accept notification success", NSLogPrefix);
            }
            
            if ([self.delegate respondsToSelector:@selector(didAcceptNotificationSuccess)]) {
                [self.delegate didAcceptNotificationSuccess];
            }
        }
        else { // Something went wrong. So, get error msg from API.
            NSString *error_msg = [[dict objectForKey:@"error"] objectForKey:@"msg"];
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefix, error_msg);
            }
            
            if ([self.delegate respondsToSelector:@selector(didAcceptNotificationFailWithErrorMessage:)]) {
                [self.delegate didAcceptNotificationFailWithErrorMessage:error_msg];
            }
        }
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ Error = %@", NSLogPrefix, exception.description);
        }
        
        if ([self.delegate respondsToSelector:@selector(didAcceptNotificationFailWithErrorMessage:)]) {
            [self.delegate didAcceptNotificationFailWithErrorMessage:DefaultErrorMsg];
        }
    }
}

#pragma mark - NSBundle Strings
- (NSString *)currentVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([self.delegate respondsToSelector:@selector(didClickFirstButtonForAlertViewTag:)]) {
            [self.delegate didClickFirstButtonForAlertViewTag:alertView.tag];
        }
    }
    else if (buttonIndex == 1) {
        if ([self.delegate respondsToSelector:@selector(didClickSecondButtonForAlertViewTag:)]) {
            [self.delegate didClickSecondButtonForAlertViewTag:alertView.tag];
        }
    }
    else if (buttonIndex == 2) {
        if ([self.delegate respondsToSelector:@selector(didClickThirdButtonForAlertViewTag:)]) {
            [self.delegate didClickThirdButtonForAlertViewTag:alertView.tag];
        }
    }
}

@end
