//
//  BoardUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface BoardUtilities : NSObject

+(void)getBoardWithName:(NSString*)name
                   Mode:(int)mode
                  Count:(int)count
                   Page:(int)page
               Delegate:(id<HttpResponseDelegate>)delegate;

@end
