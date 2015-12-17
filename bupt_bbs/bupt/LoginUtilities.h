//
//  LoginUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginHttpResponseDelegate.h"

@interface LoginUtilities : NSObject

+(void)loginWithUserName:(NSString*)username
                password:(NSString*)password
                delegete:(id<LoginHttpResponseDelegate>)delegate;
@end
