//
//  TaskManager.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/6/2558 BE.
//
//

#import <Foundation/Foundation.h>

@interface TaskManager : NSObject

- (id)initWithRequest:(NSURLRequest *)request isDebug:(BOOL)isDebug;
- (void)performTaskWithCompletionHandlerOnSuccess:(void (^)(NSDictionary *responseDict))onSuccess onFailure:(void (^)(NSString *error_msg))onFailure;

@end
