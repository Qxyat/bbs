//
//  RecommedUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/14.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"

@interface RecommedUtilities : NSObject

+(void)getRecommendArticles:(id<HttpResponseDelegate>)delegate;

@end
