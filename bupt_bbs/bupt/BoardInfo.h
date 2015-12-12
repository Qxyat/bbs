//
//  BoardInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardInfo : NSObject

@property(strong,nonatomic)NSString* name;
@property(strong,nonatomic)NSString* manager;
@property(strong,nonatomic)NSString* board_description;
@property(strong,nonatomic)NSString* board_class;
@property(strong,nonatomic)NSString* section;
@property(nonatomic)       int       post_today_count;
@property(nonatomic)       int       threads_today_count;
@property(nonatomic)       int       post_threads_count;
@property(nonatomic)       int       post_all_count;
@property(nonatomic)       BOOL      is_read_only;
@property(nonatomic)       BOOL      is_no_reply;
@property(nonatomic)       BOOL      allow_attachment;
@property(nonatomic)       BOOL      allow_anonymous;
@property(nonatomic)       BOOL      allow_outgo;
@property(nonatomic)       BOOL      allow_post;
@property(nonatomic)       int       user_online_count;
@property(nonatomic)       int       user_online_max_count;
@property(nonatomic)       int       user_online_max_time;

+(NSMutableArray*)getBoardsInfo:(id)item;
+(BoardInfo*)getBoardInfo:(id)item;
@end
