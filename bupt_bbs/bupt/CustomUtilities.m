//
//  CustomUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "CustomUtilities.h"

@implementation CustomUtilities

#pragma mark - 获取发帖时间的字符串
+(NSString*) getPostTimeString:(NSUInteger) timeInterval{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    
    NSDate *today=[[NSDate alloc]init];
    NSTimeInterval secondsPerDay=24*60*60;
    NSDate *yesterday=[today dateByAddingTimeInterval:-secondsPerDay];
    NSDate *dayBeforeYesterday=[today dateByAddingTimeInterval:-2*secondsPerDay];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSString *todayString=[formatter stringFromDate:today];
    NSString *yesterdayString=[formatter stringFromDate:yesterday];
    NSString *dayBeforeYesterdayString=[formatter stringFromDate:dayBeforeYesterday];
    
    NSDate *postTime=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *postTimeString=[formatter stringFromDate:postTime];
    
    NSCalendar *calender=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSInteger units=NSCalendarUnitYear;
    
    if([postTimeString isEqualToString:todayString]){
        [formatter setDateFormat:@"HH:mm"];
    }
    else if([postTimeString isEqualToString:yesterdayString]){
        [formatter setDateFormat:@"昨天 HH:mm"];
    }
    else if([postTimeString isEqualToString:dayBeforeYesterdayString]){
        [formatter setDateFormat:@"前天 HH:mm"];
    }
    else if([[calender components:units fromDate:today]year]==
            [[calender components:units fromDate:postTime]year]){
        [formatter setDateFormat:@"MM-dd"];
    }
    else{
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }
    
    return  [formatter stringFromDate:postTime];
}

#pragma mark - 获取显示楼层的字符串
+(NSString*) getFloorString:(int) position{
    if(position==0)
        return @"楼主";
    else
        return [NSString stringWithFormat:@"%d楼",position];
}

#pragma mark - 获取显示用户性别的字符串
+(NSString *) getGenderString:(NSString *)gender{
    if([gender isEqualToString:@"m"]){
        return @"男";
    }
    else if([gender isEqualToString:@"f"])
        return @"女";
    else
        return @"这是个秘密~。~";
}

#pragma mark - 获取上次登录时间的字符串
+(NSString*) getLastLoginTimeString:(NSUInteger)timeInterval{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YY年MM月dd日  HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark - 获取显示用户在线状态的字符串
+(NSString*) getUserLoginStateString:(BOOL)isOnline{
    if(isOnline)
        return @"在线";
    else
        return @"离线";
}
#pragma mark - 获取网络请求错误代码
+(NSInteger) getNetworkErrorCode:(NSError*)error{
    if([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        return NetworkConnectFailed;
    else if([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"The request timed out."]){
        return NetworkConnectTimeout;
    }
    else
        return NetworkConnectUnknownReason;
}
@end

