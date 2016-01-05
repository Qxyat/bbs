//
//  CustomUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,NetworkErrorCode){
    NetworkConnectUnknownReason,
    NetworkConnectTimeout,
    NetworkConnectFailed,
};

@interface CustomUtilities : NSObject

#pragma mark - 获取显示发帖时间的字符串
+(NSString*) getPostTimeString:(NSUInteger) timeInterval;

#pragma mark - 获取显示楼层的字符串
+(NSString*) getFloorString:(int) position;

#pragma mark - 获取显示用户性别的字符串
+(NSString *) getGenderString:(NSString *)gender;

#pragma mark - 获取上次登录时间的字符串
+(NSString*) getLastLoginTimeString:(NSUInteger)timeInterval;

#pragma mark - 获取显示用户在线状态的字符串
+(NSString*) getUserLoginStateString:(BOOL)isOnline;

#pragma mark - 判断一个名字是否代表图片
+(bool)isPicture:(NSString *)string;

#pragma mark - 获取网络请求错误代码
+(NSInteger) getNetworkErrorCode:(NSError*)error;

#pragma mark - 根据颜色代码获得颜色
+(UIColor*) getColor:(NSString *) hexColor;
@end
