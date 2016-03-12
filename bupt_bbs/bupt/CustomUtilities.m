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
+(NSString*) getPostTimeString:(NSInteger) timeInterval{
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
    else if(position==1)
        return @"沙发";
    else if(position==2)
        return @"板凳";
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
+(NSString*) getLastLoginTimeString:(NSInteger)timeInterval{
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
#pragma mark - 判断一个名字是否代表图片
+(bool)isPicture:(NSString *)string{
    NSArray* array=[string componentsSeparatedByString:@"."];
    return [[array lastObject] caseInsensitiveCompare:@"png"]==NSOrderedSame||
    [[array lastObject]  caseInsensitiveCompare:@"jpg"]==NSOrderedSame||
    [[array lastObject]  caseInsensitiveCompare:@"jpeg"]==NSOrderedSame||
    [[array lastObject]  caseInsensitiveCompare:@"gif"]==NSOrderedSame;
}
#pragma mark - 获取网络请求错误代码
+(NSString *)getNetworkErrorInfoWithResponse:(id)response
                                   withError:(NSError*)error{
    if(response!=nil)
        return response[@"msg"];
    return error.userInfo[@"NSLocalizedDescription"];
}
#pragma mark - 根据颜色代码获得颜色
+(UIColor*) getColor:(NSString *) hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

#pragma mark - 缩放图片
+(UIImage *)image:(UIImage *)image
      scaleToSize:(CGSize)size{
    CGSize newSize;
    if(image.size.width>=image.size.height){
        newSize.width=size.width;
        newSize.height=image.size.height/image.size.width*size.width;
    }
    else{
        newSize.height=size.height;
        newSize.width=image.size.width/image.size.height*size.width;
    }
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
@end

