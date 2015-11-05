//
//  SettingViewController.h
//  EggMobilePushNotification
//
//  Created by Kittisak Phetrungnapha on 11/5/2558 BE.
//  Copyright © 2558 Kittisak Phetrungnapha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *notiSw;
@property (weak, nonatomic) IBOutlet UISwitch *soundSw;
@property (weak, nonatomic) IBOutlet UISwitch *badgeSw;

- (IBAction)notiSwAction:(id)sender;
- (IBAction)soundSwAction:(id)sender;
- (IBAction)badgeSwAction:(id)sender;

@end
