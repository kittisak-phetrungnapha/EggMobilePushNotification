//
//  EggMobilePushNotificationViewController.h
//  EggMobilePushNotification
//
//  Created by Kittisak Phetrungnapha on 10/29/2015.
//  Copyright (c) 2015 Kittisak Phetrungnapha. All rights reserved.
//

@import UIKit;

@interface EggMobilePushNotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *resultLb;
- (IBAction)subscribePressed:(id)sender;
- (IBAction)unsubscribePressed:(id)sender;

@end
