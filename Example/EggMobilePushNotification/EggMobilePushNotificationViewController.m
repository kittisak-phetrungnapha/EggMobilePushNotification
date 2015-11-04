//
//  EggMobilePushNotificationViewController.m
//  EggMobilePushNotification
//
//  Created by Kittisak Phetrungnapha on 10/29/2015.
//  Copyright (c) 2015 Kittisak Phetrungnapha. All rights reserved.
//

#import "EggMobilePushNotificationViewController.h"

@interface EggMobilePushNotificationViewController () <EggMobilePushNotificationManagerDelegate>

@end

@implementation EggMobilePushNotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [EggMobilePushNotificationManager sharedInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[EggMobilePushNotificationManager sharedInstance] showAlertViewForTitle:@"Title test" message:@"Message test" firstButtonTitle:@"Cancel" secondButtonTitle:@"OK" thirdButtonTitle:@"Reset" viewControllerToPresent:self tag:200];
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
