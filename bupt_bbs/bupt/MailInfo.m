//
//  MailInfo.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailInfo.h"
#import "AttachmentInfo.h"
#import "UserInfo.h"

static NSString* const kIndx=@"index";
static NSString* const kIs_M=@"is_m";
static NSString* const kIs_Read=@"is_read";
static NSString* const kIs_Reply=@"is_reply";
static NSString* const kHas_Attachment=@"has_attachment";
static NSString* const kTitle=@"title";
static NSString* const kUser=@"user";
static NSString* const kPost_Time=@"post_time";
static NSString* const kBox_Name=@"box_name";
static NSString* const kContent=@"content";
static NSString* const kAttachmentInfo=@"attachment";

@implementation MailInfo
+(NSMutableArray*)getMailsInfo:(id)items{
    NSMutableArray *data=nil;
    if(items!=[NSNull null]){
        NSArray *array=(NSArray *)items;
        data=[[NSMutableArray alloc]initWithCapacity:array.count];
        for(int i=0;i<array.count;i++)
            [data addObject:[MailInfo getMailInfo:array[i]]];
    }
    return data;
}
+(MailInfo*)getMailInfo:(id)item{
    MailInfo *mail=[[MailInfo alloc]init];
    NSDictionary *dic=(NSDictionary*)item;
    
    mail.index=[[dic objectForKey:kIndx] integerValue];
    mail.is_m=[[dic objectForKey:kIs_M] boolValue];
    mail.is_read=[[dic objectForKey:kIs_Read] boolValue];
    mail.is_reply=[[dic objectForKey:kIs_Reply] boolValue];
    mail.has_attachment=[[dic objectForKey:kHas_Attachment] boolValue];
    mail.title=[dic objectForKey:kTitle];
    
    if([[dic objectForKey:kUser] isKindOfClass:[NSDictionary class]]){
        mail.isUserExist=YES;
        mail.user=[UserInfo getUserInfo:[dic objectForKey:kUser]];
    }
    else{
        mail.isUserExist=NO;
        mail.user=[dic objectForKey:kUser];
    }
    
    mail.post_time=[[dic objectForKey:kPost_Time]integerValue];
    mail.box_name=[dic objectForKey:kBox_Name];
    mail.content=[dic objectForKey:kContent];
    
    mail.attachmentInfo=[AttachmentInfo getAttachmentInfo:[dic objectForKey:kAttachmentInfo]];
    return mail;
}
@end
