//
//  AttachmentFile.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/6.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "AttachmentFile.h"

static NSString * const kName=@"name";
static NSString * const kUrl=@"url";
static NSString * const kSize=@"size";
static NSString * const kThumbnailSmall=@"thumbnail_small";
static NSString * const kThumbnailMiddle=@"thumbnail_middle";

@implementation AttachmentFile

+(NSArray*)getAttachmentFiles:(id)item{
    NSMutableArray *mutableArray=nil;
    if(item!=[NSNull null]&&item!=nil){
        NSArray *array=(NSArray*)item;
        mutableArray=[[NSMutableArray alloc]initWithCapacity:[array count]];
        for(int i=0;i<[array count];i++)
            [mutableArray addObject:[AttachmentFile getAttachmentFile:array[i]]];
    }
    return mutableArray;
}
+(AttachmentFile *)getAttachmentFile:(id)item{
    AttachmentFile *attachmentFile=nil;
    if(item!=[NSNull null]&&item!=nil){
        NSDictionary *dic=(NSDictionary *)item;
        attachmentFile=[[AttachmentFile alloc]init];
        attachmentFile.name=[dic objectForKey:kName];
        attachmentFile.url=[dic objectForKey:kUrl];
        attachmentFile.size=[dic objectForKey:kSize];
        attachmentFile.thumbnail_small=[dic objectForKey:kThumbnailSmall];
        attachmentFile.thumbnail_middle=[dic objectForKey:kThumbnailMiddle];
    }
    return  attachmentFile;
}
@end
