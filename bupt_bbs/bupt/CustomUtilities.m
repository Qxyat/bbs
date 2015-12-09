//
//  CustomUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "CustomUtilities.h"

@implementation CustomUtilities

#pragma mark - 获取显示当前时间的字符串
+(NSString*) getTimeString:(NSUInteger) timeInterval{
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
+(NSString*) getFloorString:(NSUInteger) position{
    if(position==0)
        return @"楼主";
    else
        return [NSString stringWithFormat:@"%d楼",position];
}

@end

