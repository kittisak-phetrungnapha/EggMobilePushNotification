//
//  EPAlertViewManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/11/2558 BE.
//
//

#import <Foundation/Foundation.h>

@interface EPAlertViewManager : NSObject

@property (nonatomic) BOOL isDebug;
@property (nonatomic) BOOL quitAppWhenClickClose;

+ (EPAlertViewManager *)sharedInstance;
- (void)parseWithDict:(NSDictionary *)dict;
- (void)showAlertView;

@end
