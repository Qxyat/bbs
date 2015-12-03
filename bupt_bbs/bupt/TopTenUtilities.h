//
//  TopTenUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/1.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface TopTenUtilities : NSObject

+(void)getTopTenArticles:(id<HttpResponseDelegate>) delegate;

@end
