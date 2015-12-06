//
//  Article.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfo;
@class AttachmentInfo;

@interface ArticleInfo : NSObject

@property(nonatomic) int articleId;
@property(nonatomic) int group_id;
@property(nonatomic) int reply_id;
@property(strong,nonatomic) NSString *flag;
@property(nonatomic) int position;
@property(nonatomic) Boolean is_top;
@property(nonatomic) Boolean is_subject;
@property(nonatomic) Boolean has_attachment;
@property(nonatomic) Boolean is_admin;
@property(strong,nonatomic) NSString *title;
@property(strong,nonatomic) UserInfo *user;
@property(nonatomic) int post_time;
@property(strong,nonatomic) NSString *board_name;
@property(strong,nonatomic) NSString *content;
@property(strong,nonatomic) AttachmentInfo *attachment;
@property(nonatomic) int previous_id;
@property(nonatomic) int next_id;
@property(nonatomic) int threads_previous_id;
@property(nonatomic) int threads_next_id;
@property(nonatomic) int reply_count;
@property(strong,nonatomic) NSString*last_reply_user_id;
@property(nonatomic) int last_reply_time;

+(NSArray*)getArticlesInfo:(id)item;
+(ArticleInfo *)getArticleInfo:(id)item;
@end
