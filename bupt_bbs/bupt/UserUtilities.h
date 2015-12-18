//
//  UserUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserHttpResponseDelegate.h"

@interface UserUtilities : NSObject

+(void)getLoginUserInfo:(id<UserHttpResponseDelegate>)delegate;

@end
