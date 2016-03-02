//
//  FavoriteUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 16/3/1.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface FavoriteUtilities : NSObject
+(void)getFavoriteInfoWithLevel:(NSUInteger)level
                   withDelegate:(id<HttpResponseDelegate>)delegate;
@end
