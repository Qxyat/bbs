//
//  SectionUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface SectionUtilities : NSObject

+(void)getSections:(id<HttpResponseDelegate>)delegate;

+(void)getSpecifiedSectionsWithName:(NSString*)name delegate:(id<HttpResponseDelegate>)delegate;

+(void)getSubSectionsWithName:(NSArray*)array delegate:(id<HttpResponseDelegate>)delegate;
@end
