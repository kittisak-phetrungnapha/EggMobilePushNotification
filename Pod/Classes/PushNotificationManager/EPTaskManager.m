//
//  EPTaskManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/6/2558 BE.
//
//

#import "EPTaskManager.h"

NSString *const NSLogPrefixTaskClass                 = @"EPTaskManager log:";
NSString *const DefaultErrorMessage                  = @"The unknown error is occured.";

@interface EPTaskManager ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) BOOL isDebug;

@end

@implementation EPTaskManager

- (id)initWithRequest:(NSURLRequest *)request isDebug:(BOOL)isDebug {
    self = [super init];
    if (self) {
        self.request = request;
        self.isDebug = isDebug;
    }
    return self;
}

- (void)performTaskWithCompletionHandlerOnSuccess:(void (^)(NSDictionary *responseDict))onSuccess onFailure:(void (^)(NSString *error_msg))onFailure
{
    if (self.isDebug) {
        NSLog(@"%@ Url request = %@", NSLogPrefixTaskClass, self.request.URL.absoluteString);
        NSLog(@"%@ Parameter = %@", NSLogPrefixTaskClass, [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding]);
        NSLog(@"%@ Method = %@", NSLogPrefixTaskClass, self.request.HTTPMethod);
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        @try {
            if (error == nil && data.length > 0) { // Success
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                // Check response from server.
                if (appData == nil) { // Invalid data
                    if (self.isDebug) {
                        NSLog(@"%@ Error = %@", NSLogPrefixTaskClass, DefaultErrorMessage);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        onFailure(DefaultErrorMessage);
                    });
                    return ;
                }
                
                if (self.isDebug) {
                    NSLog(@"%@ JSON Success = %@", NSLogPrefixTaskClass, appData);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    onSuccess(appData);
                });
            }
            else { // Fail
                if (self.isDebug) {
                    NSLog(@"%@ Error = %@", NSLogPrefixTaskClass, [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    onFailure([error.userInfo objectForKey:@"NSLocalizedDescription"]);
                });
            }
        }
        @catch (NSException *exception) {
            if (self.isDebug) {
                NSLog(@"%@ Error = %@", NSLogPrefixTaskClass, exception.description);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                onFailure(DefaultErrorMessage);
            });
        }
    }];
    
    // Start task
    [task resume];
}

@end
