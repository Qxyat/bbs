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

@implementation ArticlePreProcessingUtilities
#pragma mark - 预加载一页文章所需要的图片
+(void)onePageArticlesPreProcess:(NSArray*)array{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for(int i=0;i<array.count;i++){
            ArticleInfo *articleInfo=(ArticleInfo*)array[i];
            [ArticlePreProcessingUtilities oneArticlePreProcessing:articleInfo];
        }
    });
}

#pragma mark - 预加载一篇文章所需要的图片
+(void)oneArticlePreProcessing:(ArticleInfo*)articleInfo
{
    NSScanner *scanner=[[NSScanner alloc]initWithString:articleInfo.content];
    scanner.charactersToBeSkipped=nil;
    NSString *tmp;
  
    while(![scanner isAtEnd]){
        if([scanner scanString:@"[em" intoString:nil]){
            scanner.scanLocation-=2;
            [scanner scanUpToString:@"]" intoString:&tmp];
            [DownloadResourcesUtilities downLoadEmoji:tmp Completed:nil];
            [scanner scanString:@"]" intoString:nil];
        }
        else{
            scanner.scanLocation++;
        }
    }
    AttachmentInfo *attachmentInfo=articleInfo.attachment;
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
        for(int i=0;i<attachmentInfo.file.count;i++){
            AttachmentFile *file=attachmentInfo.file[i];
            if([CustomUtilities isPicture:file.name]){
                [DownloadResourcesUtilities downloadPicture:file.thumbnail_middle FromBBS:YES Completed:nil];
            }
        }
    }
}
@end
