//
//  EggMobilePushNotificationViewController.m
//  EggMobilePushNotification
//
//  Created by Kittisak Phetrungnapha on 10/29/2015.
//  Copyright (c) 2015 Kittisak Phetrungnapha. All rights reserved.
//

#import "EggMobilePushNotificationViewController.h"
#import "SettingViewController.h"

@interface EggMobilePushNotificationViewController () <EggMobilePushNotificationManagerDelegate>

@end

@implementation EggMobilePushNotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingPage)];
    self.navigationItem.rightBarButtonItem = settingBtn;
    
    [EggMobilePushNotificationManager sharedInstance].delegate = self;
}

- (void)showSettingPage {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController *vc = (SettingViewController *)[sb instantiateViewControllerWithIdentifier:@"settingNav"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)subscribePressed:(id)sender {
    [[EggMobilePushNotificationManager sharedInstance] subscribeOnSuccess:^{
        self.resultLb.text = @"Subscribe success.";
    } onFailure:^(NSString *error_msg) {
        self.resultLb.text = [NSString stringWithFormat:@"Subscribe fail with error = %@", error_msg];
    }];
}

- (IBAction)unsubscribePressed:(id)sender {
    [[EggMobilePushNotificationManager sharedInstance] unsubscribeOnSuccess:^{
        self.resultLb.text = @"Unsubscribe success.";
    } onFailure:^(NSString *error_msg) {
        self.resultLb.text = [NSString stringWithFormat:@"Unsubscribe fail with error = %@", error_msg];
    }];
}

#pragma mark - EggMobilePushNotificationManagerDelegate
- (void)didClickFirstButtonForAlertViewTag:(NSInteger)tag {
    NSLog(@"TAG = %ld", tag);
    NSLog(@"%s", __FUNCTION__);
}

- (void)didClickSecondButtonForAlertViewTag:(NSInteger)tag {
    NSLog(@"TAG = %ld", tag);
    NSLog(@"%s", __FUNCTION__);
}

- (void)didClickThirdButtonForAlertViewTag:(NSInteger)tag {
    NSLog(@"TAG = %ld", tag);
    NSLog(@"%s", __FUNCTION__);
}

@end
