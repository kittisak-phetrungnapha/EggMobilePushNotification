//
//  TaskManager.m
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/6/2558 BE.
//
//

#import "TaskManager.h"

NSString *const DefaultErrorMessage         = @"The unknown error is occured.";

@interface TaskManager ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) BOOL isDebug;

@end

@implementation TaskManager

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
        NSLog(@"TaskManager: Url request = %@", self.request.URL.absoluteString);
        NSLog(@"TaskManager: Parameter = %@", self.request.HTTPBody.description);
        NSLog(@"TaskManager: Method = %@", self.request.HTTPMethod);
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        @try {
            if (error == nil && data.length > 0) { // Success
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                // Check response from server.
                if (appData == nil) { // Invalid data
                    if (self.isDebug) {
                        NSLog(@"TaskManager: Error = %@", DefaultErrorMessage);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        onFailure(DefaultErrorMessage);
                    });
                    return ;
                }
                
                if (self.isDebug) {
                    NSLog(@"TaskManager: Perform task success");
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    onSuccess(appData);
                });
            }
            else { // Fail
                if (self.isDebug) {
                    NSLog(@"TaskManager: Error = %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    onFailure([error.userInfo objectForKey:@"NSLocalizedDescription"]);
                });
            }
        }
        @catch (NSException *exception) {
            if (self.isDebug) {
                NSLog(@"TaskManager: Error = %@", exception.description);
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
