//
//  Article.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfo;

@interface ArticleInfo : NSObject

@property(nonatomic) int articleId;
@property(strong,nonatomic) NSString *title;
@property(strong,nonatomic) UserInfo *user;
@property(nonatomic) int post_time;
@property(strong,nonatomic) NSString *board_name;
@property(nonatomic) int reply_count;

+(NSMutableArray*)getArticlesInfo:(NSArray*)array;
+(ArticleInfo *)getArticleInfo:(NSDictionary*)dic;
@end
