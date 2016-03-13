//
//  SectionUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SectionHttpResponseDelegate.h"

@interface SectionUtilities : NSObject

+(void)getSections:(id<SectionHttpResponseDelegate>)delegate;

+(void)getSpecifiedSectionWithName:(NSString*)name
               isSubSectionRequest:(BOOL)isSubSectionRequest
                          subIndex:(NSUInteger)index
                          delegate:(id<SectionHttpResponseDelegate>)delegate;

//+(void)getSubSectionsWithName:(NSArray*)array delegate:(id<HttpResponseDelegate>)delegate;
@end
