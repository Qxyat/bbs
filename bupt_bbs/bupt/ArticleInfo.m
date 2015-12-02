//
//  Article.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ArticleInfo.h"
#import "UserInfo.h"

static NSString* const kArticleId=@"id";
static NSString* const kTitle=@"title";
static NSString* const kUser=@"user";
static NSString* const kPostTime=@"post_time";
static NSString* const kBoardName=@"board_name";
static NSString* const kReplyCount=@"reply_count";

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
    articleInfo.title=[dic objectForKey:kTitle];
    articleInfo.user=[UserInfo getUserInfo:[dic objectForKey:kUser]];
    articleInfo.post_time=[[dic objectForKey:kPostTime] intValue];
    articleInfo.board_name=[dic objectForKey:kBoardName];
    articleInfo.reply_count=[[dic objectForKey:kReplyCount] intValue];
    return articleInfo;
}
@end
