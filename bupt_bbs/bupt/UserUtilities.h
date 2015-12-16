//
//  UserUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"

@interface UserUtilities : NSObject

+(void)getLoginUserInfo:(id<HttpResponseDelegate>)delegate;

@end
