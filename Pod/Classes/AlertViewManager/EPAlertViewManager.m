//
//  EPAlertViewManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/11/2558 BE.
//
//

#import "EPAlertViewManager.h"

NSString *const NSLogPrefixEPAlertViewManager   = @"EPAlertViewManager log:";
NSInteger const EPAlertViewTag                  = 15423;

NSString *const EPActionCall                    = @"call";
NSString *const EPActionSMS                     = @"sms";
NSString *const EPActionOpenWeb                 = @"url";

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
    if ([EPActionCall isEqualToString:action]) {
        [self openURLWithScheme:[NSString stringWithFormat:@"telprompt:%@", value]];
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
        
        NSString *smsScheme;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            smsScheme = [NSString stringWithFormat:@"sms:%@&body=%@", tel, message];
        }
        else {
            smsScheme = [NSString stringWithFormat:@"sms:%@;body=%@", tel, message];
        }
        
        [self openURLWithScheme:smsScheme];
    }
    else if ([EPActionOpenWeb isEqualToString:action]) {
        [self openURLWithScheme:value];
    }
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
        
        /*** Check all of button in uialertview need to show or not. ***/
        
        // Negative button
        if (! ([@"" isEqualToString:self.noti_negative_button_title] || [@"" isEqualToString:self.noti_negative_button_action])) {
            [alertView addButtonWithTitle:self.noti_negative_button_title];
        }
        
        // Positive button
        if (! ([@"" isEqualToString:self.noti_positive_button_title] || [@"" isEqualToString:self.noti_positive_button_action])) {
            [alertView addButtonWithTitle:self.noti_positive_button_title];
        }
        
        // New button
        if (! ([@"" isEqualToString:self.noti_new_button_title] || [@"" isEqualToString:self.noti_new_button_action]))
        {
            [alertView addButtonWithTitle:self.noti_new_button_title];
        }
        
        // Show alert view
        [alertView show];
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

@end
