//
//  EPConnectionManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/9/2558 BE.
//
//

#import "EPConnectionManager.h"

@implementation EPConnectionManager

+ (EPNetworkStatus)checkNetworkStatus {
    EPReachability *reachability = [EPReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    EPNetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];
    return status;
}

@end
