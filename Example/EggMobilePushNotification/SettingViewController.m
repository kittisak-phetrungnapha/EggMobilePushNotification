//
//  SettingViewController.m
//  EggMobilePushNotification
//
//  Created by Kittisak Phetrungnapha on 11/5/2558 BE.
//  Copyright © 2558 Kittisak Phetrungnapha. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSettingPage)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.notiSw setOn:[EggMobilePushNotificationNSUserDefaultsManager getNotificationState] animated:YES];
    [self.soundSw setOn:[EggMobilePushNotificationNSUserDefaultsManager getSoundState] animated:YES];
    [self.badgeSw setOn:[EggMobilePushNotificationNSUserDefaultsManager getBadgeState] animated:YES];
}

- (void)dismissSettingPage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)notiSwAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    [[EggMobilePushNotificationManager sharedInstance] setTurnOnNotification:sw.isOn onSuccess:^{
        NSLog(@"Change noti state success.");
    } onFailure:^(NSString *error_msg) {
        [sw setOn:!sw.isOn animated:YES];
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];
}

- (IBAction)soundSwAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    
    [[EggMobilePushNotificationManager sharedInstance] setTurnOnSound:sw.isOn onSuccess:^{
        NSLog(@"Change sound state success.");
    } onFailure:^(NSString *error_msg) {
        [sw setOn:!sw.isOn animated:YES];
    }];
}

- (IBAction)badgeSwAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    
    [[EggMobilePushNotificationManager sharedInstance] setTurnOnBadge:sw.isOn onSuccess:^{
        NSLog(@"Change badge state success.");
    } onFailure:^(NSString *error_msg) {
        [sw setOn:!sw.isOn animated:YES];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.notiSw.isOn) {
        return 3;
    }
    else {
        return 1;
    }
}

@end
