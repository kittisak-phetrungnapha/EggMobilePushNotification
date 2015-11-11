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
        self.resultLb.text = @"Change noti state success.";
    } onFailure:^(NSString *error_msg) {
        [sw setOn:!sw.isOn animated:YES];
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        self.resultLb.text = [NSString stringWithFormat:@"Change noti state fail with error = %@", error_msg];
    }];
}

- (IBAction)soundSwAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    
    [[EggMobilePushNotificationManager sharedInstance] setTurnOnSound:sw.isOn onSuccess:^{
        self.resultLb.text = @"Change sound state success.";
    } onFailure:^(NSString *error_msg) {
        [sw setOn:!sw.isOn animated:YES];
        
        self.resultLb.text = [NSString stringWithFormat:@"Change sound state fail with error = %@", error_msg];
    }];
}

- (IBAction)badgeSwAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    
    [[EggMobilePushNotificationManager sharedInstance] setTurnOnBadge:sw.isOn onSuccess:^{
        self.resultLb.text = @"Change badge state success.";
    } onFailure:^(NSString *error_msg) {
        [sw setOn:!sw.isOn animated:YES];
        
        self.resultLb.text = [NSString stringWithFormat:@"Change badge state fail with error = %@", error_msg];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.notiSw.isOn) {
            return 3;
        }
        else {
            return 1;
        }
    }
    else {
        return 1;
    }
}

@end
