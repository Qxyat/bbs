//
//  BoardInfo.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BoardInfo.h"

static NSString* const kName=@"name";
static NSString* const kManager=@"manager";
static NSString* const kBoardDescription=@"description";
static NSString* const kBoardClass=@"class";
static NSString* const kSection=@"section";
static NSString* const kPostTodayCount=@"post_today_count";
static NSString* const kThreadTodayCount=@"threads_today_count";
static NSString* const kPostThreadsCount=@"post_threads_count";
static NSString* const kPostAllCount=@"post_all_count";
static NSString* const kIsReadOnly=@"is_read_only";
static NSString* const kIsNoReply=@"is_no_reply";
static NSString* const kAllowAttachment=@"allow_attachment";
static NSString* const kAllowAnonymous=@"allow_anonymous";
static NSString* const kAllowOutgo=@"allow_outgo";
static NSString* const kAllowPost=@"allow_post";
static NSString* const kUserOnlineCount=@"user_online_count";
static NSString* const kUserOnlineMaxCount=@"user_online_max_count";
static NSString* const kUserOnlineMaxTime=@"user_online_max_time";

@implementation BoardInfo

#pragma mark - 获取所有版面信息列表
+(NSMutableArray*)getBoardsInfo:(id)item{
    NSMutableArray *data=nil;
    if(item!=[NSNull null]){
        NSArray *array=(NSArray *)item;
        data=[[NSMutableArray alloc]initWithCapacity:array.count];
        for(int i=0;i<array.count;i++)
            [data addObject:[BoardInfo getBoardInfo:array[i]]];
    }
    return data;
}

#pragma mark - 获取单个版面信息
+(BoardInfo*)getBoardInfo:(id)item{
    BoardInfo *boardInfo=[[BoardInfo alloc]init];
    NSDictionary *dic=(NSDictionary*)item;
    
    boardInfo.name=[dic objectForKey:kName];
    boardInfo.manager=[dic objectForKey:kManager];
    boardInfo.board_description=[dic objectForKey:kBoardDescription];
    boardInfo.board_class=[dic objectForKey:kBoardClass];
    boardInfo.section=[dic objectForKey:kSection];
    boardInfo.post_today_count=[[dic objectForKey:kPostTodayCount]intValue];
    boardInfo.threads_today_count=[[dic objectForKey:kThreadTodayCount]intValue];
    boardInfo.post_threads_count=[[dic objectForKey:kPostThreadsCount]intValue];
    boardInfo.post_all_count=[[dic objectForKey:kPostAllCount]intValue];
    boardInfo.is_read_only=[[dic objectForKey:kIsReadOnly]boolValue];
    boardInfo.is_no_reply=[[dic objectForKey:kIsNoReply]boolValue];
    boardInfo.allow_attachment=[[dic objectForKey:kAllowAttachment]boolValue];
    boardInfo.allow_anonymous=[[dic objectForKey:kAllowAnonymous]boolValue];
    boardInfo.allow_outgo=[[dic objectForKey:kAllowOutgo]boolValue];
    boardInfo.allow_post=[[dic objectForKey:kAllowPost]boolValue];
    boardInfo.user_online_count=[[dic objectForKey:kUserOnlineCount]intValue];
    boardInfo.user_online_max_count=[[dic objectForKey:kUserOnlineMaxCount]intValue];
    boardInfo.user_online_max_time=[[dic objectForKey:kUserOnlineMaxTime]intValue];
    
    return boardInfo;
}
@end
