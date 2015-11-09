//
//  ConnectionManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/9/2558 BE.
//
//

#import "ConnectionManager.h"

@implementation ConnectionManager

+ (EPNetworkStatus)checkNetworkStatus {
    EPReachability *reachability = [EPReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    EPNetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];
    return status;
}

@end
