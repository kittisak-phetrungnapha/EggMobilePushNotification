//
//  EPResponseObject.h
//  Pods
//
//  Created by Kittisak Phetrungnapha on 11/6/2558 BE.
//
//

#import <Foundation/Foundation.h>

@interface EPResponseObject : NSObject

@property (nonatomic, strong) NSString *error_msg;
@property (nonatomic) BOOL isSuccess;

@end
