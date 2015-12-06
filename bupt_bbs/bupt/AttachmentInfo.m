//
//  AttachmentInfo.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "AttachmentInfo.h"
#import "AttachmentFile.h"

static NSString *const kFile=@"file";
static NSString *const kRemainSpace=@"remain_space";
static NSString *const kRemainCount=@"remain_count";

@implementation AttachmentInfo

+(AttachmentInfo*)getAttachmentInfo:(id)item{
    AttachmentInfo *attachmentInfo=nil;
    if(item!=[NSNull null]&&item!=nil){
        NSDictionary *dic=(NSDictionary *)item;
        attachmentInfo=[[AttachmentInfo alloc]init];
        attachmentInfo.remain_space=[dic objectForKey:kRemainSpace];
        attachmentInfo.remain_count=[[dic objectForKey:kRemainCount]intValue];
        attachmentInfo.file=[AttachmentFile getAttachmentFiles:[dic objectForKey:kFile]];
    }
    return attachmentInfo;
}

@end
