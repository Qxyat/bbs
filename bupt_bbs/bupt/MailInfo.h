//
//  MailInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  AttachmentInfo;

@interface MailInfo : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL is_m;
@property (nonatomic) BOOL is_read;
@property (nonatomic) BOOL is_reply;
@property (nonatomic) BOOL has_attachment;
@property (copy,nonatomic) NSString* title;
@property (nonatomic) BOOL isExist;
@property (strong,nonatomic) id user;
@property (nonatomic) NSInteger post_time;
@property (copy,nonatomic) NSString* box_name;
@property (copy,nonatomic) NSString* content;
@property (strong,nonatomic)AttachmentInfo *attachmentInfo;

+(NSMutableArray*)getMailsInfo:(id)items;
@end
