//
//  Article.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ArticleInfo.h"
#import "UserInfo.h"
#import "AttachmentInfo.h"

static NSString* const kArticleId=@"id";
static NSString* const kGroupId=@"group_id";
static NSString* const kReplyId=@"reply_id";
static NSString* const kFlag=@"flag";
static NSString* const kPosition=@"position";
static NSString* const kIsTop=@"is_top";
static NSString* const kIsSubject=@"is_subject";
static NSString* const kHasAttachment=@"has_attachment";
static NSString* const kIsAdmin=@"is_admin";
static NSString* const kTitle=@"title";
static NSString* const kUser=@"user";
static NSString* const kPostTime=@"post_time";
static NSString* const kBoardName=@"board_name";
static NSString* const kContent=@"content";
static NSString* const kAttachment=@"*attachment";
static NSString* const kPreviousId=@"previous_id";
static NSString* const kNextId=@"next_id";
static NSString* const kThreadPreviousId=@"threads_previous_id";
static NSString* const kThreadNextId=@"threads_next_id";
static NSString* const kReplyCount=@"reply_count";
static NSString* const kLastReplyUserId=@"last_reply_user_id";
static NSString* const kLastReplyTime=@"last_reply_time";

@implementation ArticleInfo
#pragma mark - 得到一页当中所有的文章的信息
+(NSMutableArray*)getArticlesInfo:(NSArray*)array{
    NSMutableArray *mutableArray=[[NSMutableArray alloc]init];
    for(int i=0;i<array.count;i++){
        [mutableArray addObject:[ArticleInfo getArticleInfo:array[i]]];
    }
    return mutableArray;
}
#pragma mark - 得到一篇文章的信息
+(ArticleInfo *)getArticleInfo:(NSDictionary *)dic{
    ArticleInfo * articleInfo=[[ArticleInfo alloc]init];
    articleInfo.articleId=[[dic objectForKey:kArticleId] intValue];
    articleInfo.group_id=[[dic objectForKey:kGroupId] intValue];
    articleInfo.reply_id=[[dic objectForKey:kReplyId] intValue];
    articleInfo.flag=[dic objectForKey:kFlag];
    articleInfo.position=[[dic objectForKey:kPosition] intValue];
    articleInfo.is_top=[[dic objectForKey:kIsTop] boolValue];
    articleInfo.is_subject=[[dic objectForKey:kIsSubject] boolValue];
    articleInfo.has_attachment=[[dic objectForKey:kHasAttachment] boolValue];
    articleInfo.is_admin=[[dic objectForKey:kIsAdmin] boolValue];
    articleInfo.title=[dic objectForKey:kTitle];
    articleInfo.user=[UserInfo getUserInfo:[dic objectForKey:kUser]];
    articleInfo.post_time=[[dic objectForKey:kPostTime] intValue];
    articleInfo.board_name=[dic objectForKey:kBoardName];
    articleInfo.content=[dic objectForKey:kContent];
    articleInfo.attachment=[AttachmentInfo getAttachmentInfo:[dic objectForKey:kAttachment]];
    articleInfo.previous_id=[[dic objectForKey:kPreviousId]intValue];
    articleInfo.next_id=[[dic objectForKey:kNextId] intValue];
    articleInfo.threads_previous_id=[[dic objectForKey:kThreadPreviousId] intValue];
    articleInfo.threads_next_id=[[dic objectForKey:kThreadNextId] intValue];
    articleInfo.reply_count=[[dic objectForKey:kReplyCount] intValue];
    articleInfo.last_reply_user_id=[dic objectForKey:kLastReplyUserId];
    articleInfo.last_reply_time=[[dic objectForKey:kLastReplyTime] intValue];
    
    return articleInfo;
}
@end
