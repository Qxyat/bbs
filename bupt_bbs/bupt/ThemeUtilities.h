//
//  ThemeUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface ThemeUtilities : NSObject

+(void)getThemeWithBoardName:(NSString*)board_name groupId:(int)group_id
                   pageIndex:(int)page countOfOnePage:(int)count
                    delegate:(id<HttpResponseDelegate>)delegate;

@end
