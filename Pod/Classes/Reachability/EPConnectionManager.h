//
//  EPConnectionManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/9/2558 BE.
//
//

#import <Foundation/Foundation.h>
#import "EPReachability.h"

@interface EPConnectionManager : NSObject

+ (EPNetworkStatus)checkNetworkStatus;

@end
