//
//  CustomUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomUtilities : NSObject

#pragma mark - 获取显示当前时间的字符串
+(NSString*) getTimeString:(NSUInteger) timeInterval;

#pragma mark - 获取显示楼层的字符串
+(NSString*) getFloorString:(NSUInteger) position;

@end
