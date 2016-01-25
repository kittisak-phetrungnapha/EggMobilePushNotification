//
//  EPAlertViewManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/11/2558 BE.
//
//

#import "EPAlertViewManager.h"
#import "EggMobilePushNotificationManager.h"

NSString *const NSLogPrefixEPAlertViewManager   = @"EPAlertViewManager log:";
NSInteger const EPAlertViewTag                  = 15423;

NSString *const EPActionCall                    = @"call";
NSString *const EPActionSMS                     = @"sms";
NSString *const EPActionOpenWeb                 = @"url";
NSString *const EPActionClose                   = @"close";

NSString *const EPTitleCall                     = @"Call";
NSString *const EPTitleClose                    = @"Close";

@interface EPAlertViewManager () <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *noti_full_title;
@property (nonatomic, strong) NSString *noti_sender_name;

@property (nonatomic, strong) NSString *noti_negative_button_action;
@property (nonatomic, strong) NSString *noti_negative_button_title;
@property (nonatomic, strong) NSString *noti_negative_button_value;

@property (nonatomic, strong) NSString *noti_new_button_action;
@property (nonatomic, strong) NSString *noti_new_button_title;
@property (nonatomic, strong) NSString *noti_new_button_value;

@property (nonatomic, strong) NSString *noti_positive_button_action;
@property (nonatomic, strong) NSString *noti_positive_button_title;
@property (nonatomic, strong) NSString *noti_positive_button_value;

@property (nonatomic, strong) NSString *noti_ref;

@property (nonatomic, strong) UIWindow *blackWindow;

@end

@implementation EPAlertViewManager

#pragma mark - Initialization
+ (EPAlertViewManager *)sharedInstance
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
    }
    return self;
}

#pragma mark - Parse data
- (void)parseWithDict:(NSDictionary *)dict {
    @try {
        self.noti_sender_name = [dict objectForKey:@"noti_sender_name"];
        self.noti_full_title = [dict objectForKey:@"noti_full_title"];
        
        // Negative button
        NSDictionary *negativeDict = [self parseJsonString:[dict objectForKey:@"noti_negative_button"]];
        self.noti_negative_button_action = [negativeDict objectForKey:@"action"];
        self.noti_negative_button_title = [negativeDict objectForKey:@"title"];
        self.noti_negative_button_value = [negativeDict objectForKey:@"value"];
        
        // Positive button
        NSDictionary *positiveDict = [self parseJsonString:[dict objectForKey:@"noti_positive_button"]];
        self.noti_positive_button_action = [positiveDict objectForKey:@"action"];
        self.noti_positive_button_title = [positiveDict objectForKey:@"title"];
        self.noti_positive_button_value = [positiveDict objectForKey:@"value"];
        
        // New button
        NSDictionary *newDict = [self parseJsonString:[dict objectForKey:@"noti_new_button"]];
        self.noti_new_button_action = [newDict objectForKey:@"action"];
        self.noti_new_button_title = [newDict objectForKey:@"title"];
        self.noti_new_button_value = [newDict objectForKey:@"value"];
        
        // Noti ref
        self.noti_ref = [dict objectForKey:@"noti_ref"];
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefixEPAlertViewManager, exception.description);
        }
    }
}

- (NSDictionary *)parseJsonString:(NSString *)jsonString {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return jsonDict;
}

#pragma mark - Handler AlertView action
- (void)performAlertWithAction:(NSString *)action value:(NSString *)value {
    action = [action lowercaseString];
    
    if ([EPActionCall isEqualToString:action]) {
        [self openURLWithScheme:[NSString stringWithFormat:@"tel:%@", value]];
        [self removeBlackWindow];
    }
    else if ([EPActionSMS isEqualToString:action]) {
        NSArray *values = [value componentsSeparatedByString:@","];
        NSString *tel = values[0];
        
        NSMutableString *muStr = [NSMutableString stringWithString:@""];
        for (int i = 1; i < values.count; i++) {
            NSString *appendStr;
            if (i == 1) {
                appendStr = values[i];
            }
            else {
                appendStr = [NSString stringWithFormat:@",%@", values[i]];
            }
            
            [muStr appendString:appendStr];
        }
        NSString *message = [muStr copy];
        message = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *smsScheme;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            smsScheme = [NSString stringWithFormat:@"sms:%@&body=%@", tel, message];
        }
        else {
            smsScheme = [NSString stringWithFormat:@"sms:%@;body=%@", tel, message];
        }
        
        [self openURLWithScheme:smsScheme];
        [self removeBlackWindow];
    }
    else if ([EPActionOpenWeb isEqualToString:action]) {
        NSRange range = [value rangeOfString:@"?"];
        if (range.location != NSNotFound) { // already has ?
            value = [NSString stringWithFormat:@"%@&redirected=push", value];
        }
        else { // add ?
            value = [NSString stringWithFormat:@"%@?redirected=push", value];
        }
        
        [self openURLWithScheme:value];
        [self removeBlackWindow];
    }
    else { // Close ation if it first launch
        if (self.quitAppWhenClickClose) {
            exit(0);
        }
        else {
            [self removeBlackWindow];
        }
    }
    
    self.quitAppWhenClickClose = NO;
}

- (void)openURLWithScheme:(NSString *)scheme {
    NSURL *url = [NSURL URLWithString:scheme];
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app openURL:url]) {
        NSLog(@"%@ Open scheme %@ success.", NSLogPrefixEPAlertViewManager, scheme);
    }
    else {
        NSLog(@"%@ Open scheme %@ fail.", NSLogPrefixEPAlertViewManager, scheme);
    }
}

#pragma mark - Show AlertView
- (void)showAlertView {
    @try {
        // use UIAlertView
        UIAlertView *alertView = [[UIAlertView alloc] init];
        alertView.title = self.noti_sender_name;
        alertView.message = self.noti_full_title;
        alertView.delegate = self;
        alertView.tag = EPAlertViewTag;
        
        BOOL hasClose = NO;
        /*** Check all of button in uialertview need to show or not. ***/
        
        // Negative button
        if (! ([@"" isEqualToString:self.noti_negative_button_title] || [@"" isEqualToString:self.noti_negative_button_action])) {
            if ([self compareCaseInsensitiveWithString1:EPTitleCall string2:self.noti_negative_button_title]) {
                if ([self checkPhoneNumberContainStarOrSharp:self.noti_negative_button_value]) {
                    self.noti_negative_button_title = EPTitleClose;
                    self.noti_negative_button_action = EPActionClose;
                }
            }
            [alertView addButtonWithTitle:self.noti_negative_button_title];
            
            // Check has close
            if ([self compareCaseInsensitiveWithString1:EPTitleClose string2:self.noti_negative_button_title]) {
                hasClose = YES;
            }
        }
        
        // Positive button
        if (! ([@"" isEqualToString:self.noti_positive_button_title] || [@"" isEqualToString:self.noti_positive_button_action])) {
            if ([self compareCaseInsensitiveWithString1:EPTitleCall string2:self.noti_positive_button_title]) {
                if ([self checkPhoneNumberContainStarOrSharp:self.noti_positive_button_value]) {
                    if (!hasClose) {
                        self.noti_positive_button_title = EPTitleClose;
                        self.noti_positive_button_action = EPActionClose;
                        [alertView addButtonWithTitle:self.noti_positive_button_title];
                        hasClose = YES;
                    }
                }
                else {
                    [alertView addButtonWithTitle:self.noti_positive_button_title];
                }
            }
            else {
                if ([self compareCaseInsensitiveWithString1:EPTitleClose string2:self.noti_positive_button_title]) {
                    if (!hasClose) {
                        [alertView addButtonWithTitle:self.noti_positive_button_title];
                        hasClose = YES;
                    }
                }
                else {
                    [alertView addButtonWithTitle:self.noti_positive_button_title];
                }
            }
        }
        
        // New button
        if (! ([@"" isEqualToString:self.noti_new_button_title] || [@"" isEqualToString:self.noti_new_button_action]))
        {
            if ([self compareCaseInsensitiveWithString1:EPTitleCall string2:self.noti_new_button_title]) {
                if ([self checkPhoneNumberContainStarOrSharp:self.noti_new_button_value]) {
                    if (!hasClose) {
                        self.noti_new_button_title = EPTitleClose;
                        self.noti_new_button_action = EPActionClose;
                        [alertView addButtonWithTitle:self.noti_new_button_title];
                        hasClose = YES;
                    }
                }
                else {
                    [alertView addButtonWithTitle:self.noti_new_button_title];
                }
            }
            else {
                if ([self compareCaseInsensitiveWithString1:EPTitleClose string2:self.noti_new_button_title]) {
                    if (!hasClose) {
                        [alertView addButtonWithTitle:self.noti_new_button_title];
                        hasClose = YES;
                    }
                }
                else {
                    [alertView addButtonWithTitle:self.noti_new_button_title];
                }
            }
        }
        
        // Show alert view
        [alertView show];
        
        // Add Black window
        [self addBlackWindow];
        
        // Accept notification log
        [[EggMobilePushNotificationManager sharedInstance] acceptNotificationForNotiRef:self.noti_ref onSuccess:^{
            
        } onFailure:^(NSString *error_msg) {
            
        }];
    }
    @catch (NSException *exception) {
        if (self.isDebug) {
            NSLog(@"%@ %@", NSLogPrefixEPAlertViewManager, exception.description);
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == EPAlertViewTag) {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        @try {
            if ([buttonTitle isEqualToString:self.noti_negative_button_title]) {
                [self performAlertWithAction:self.noti_negative_button_action value:self.noti_negative_button_value];
            }
            else if ([buttonTitle isEqualToString:self.noti_positive_button_title]) {
                [self performAlertWithAction:self.noti_positive_button_action value:self.noti_positive_button_value];
            }
            else if ([buttonTitle isEqualToString:self.noti_new_button_title]) {
                [self performAlertWithAction:self.noti_new_button_action value:self.noti_new_button_value];
            }
        }
        @catch (NSException *exception) {
            if (self.isDebug) {
                NSLog(@"%@ %@", NSLogPrefixEPAlertViewManager, exception.description);
            }
        }
    }
}

#pragma mark - Private method
- (BOOL)checkPhoneNumberContainStarOrSharp:(NSString *)phoneValue {
    return [phoneValue rangeOfString:@"*"].location != NSNotFound || [phoneValue rangeOfString:@"#"].location != NSNotFound;
}

- (BOOL)compareCaseInsensitiveWithString1:(NSString *)string1 string2:(NSString *)string2 {
    return [string1 caseInsensitiveCompare:string2] == NSOrderedSame;
}

- (void)addBlackWindow {
    self.blackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.blackWindow.windowLevel = UIWindowLevelAlert - 1;
    self.blackWindow.backgroundColor = [UIColor blackColor];
    self.blackWindow.rootViewController = [[UIViewController alloc] init];
    [self.blackWindow makeKeyAndVisible];
}

- (void)removeBlackWindow {
    if (self.blackWindow != nil) {
        self.blackWindow = nil;
    }
}

@end
