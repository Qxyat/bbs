//
//  ArticlePreProcessing.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "ArticlePreProcessingUtilities.h"
#import "ArticleInfo.h"
#import "AttachmentInfo.h"
#import "AttachmentFile.h"
#import "LoginManager.h"
#import "DownloadResourcesUtilities.h"
#import "CustomUtilities.h"
#import "PictureInfo.h"

@implementation ArticlePreProcessingUtilities
#pragma mark - 预加载一页文章所需要的图片
+(void)onePageArticlesPreProcess:(NSArray*)array{
    for(int i=0;i<array.count;i++){
        ArticleInfo *articleInfo=(ArticleInfo*)array[i];
        [ArticlePreProcessingUtilities oneArticlePreProcessing:articleInfo];
    }
}

#pragma mark - 预加载一篇文章所需要的图片
+(void)oneArticlePreProcessing:(ArticleInfo*)articleInfo
{
    AttachmentInfo *attachmentInfo=articleInfo.attachment;
    NSMutableArray *attachmentWhetherUsed=nil;
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
        attachmentWhetherUsed=[[NSMutableArray alloc]initWithCapacity:attachmentInfo.file.count];
        for(int i=0;i<attachmentInfo.file.count;i++)
            [attachmentWhetherUsed addObject:[NSNumber numberWithBool:NO] ];
    }
    NSScanner *scanner=[[NSScanner alloc]initWithString:articleInfo.content];
    scanner.charactersToBeSkipped=nil;
   
    articleInfo.pictures=[[NSMutableArray alloc]init];
    while(![scanner isAtEnd]){
        if([scanner scanString:@"[upload=" intoString:nil]){
            int pos=1;
            [scanner scanInt:&pos];
            [ArticlePreProcessingUtilities getPictureInArticle:articleInfo withAttachmentInfo:articleInfo.attachment withPosition:pos withAttachmentUsedInfo:attachmentWhetherUsed];
            [scanner scanString:@"][/upload]" intoString:nil];
        }
        else{
            scanner.scanLocation++;
        }
    }
    
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
        for(int i=1;i<=attachmentInfo.file.count;i++){
            [ArticlePreProcessingUtilities getPictureInArticle:articleInfo withAttachmentInfo:articleInfo.attachment withPosition:i withAttachmentUsedInfo:attachmentWhetherUsed];
        }
    }
}
#pragma mark - 预加载附件中的图片
+(void)getPictureInArticle:(ArticleInfo*)articleInfo
        withAttachmentInfo:(AttachmentInfo*)attachmentInfo
              withPosition:(NSUInteger)pos
    withAttachmentUsedInfo:(NSMutableArray *)used{
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
         if(pos<=attachmentInfo.file.count){
            AttachmentFile *file=attachmentInfo.file[pos-1];
            if([CustomUtilities isPicture:file.name]&&used[pos-1]==[NSNumber numberWithBool:NO]){
                used[pos-1]=[NSNumber numberWithBool:YES];
                [DownloadResourcesUtilities downloadPicture:file.url FromBBS:YES Completed:nil];
                PictureInfo *picture=[[PictureInfo alloc]init];
                picture.thumbnail_url=file.thumbnail_middle;
                picture.original_url=file.url;
                picture.isFromBBS=YES;
                [articleInfo.pictures addObject:picture];
            }
        }
    }

}
@end
