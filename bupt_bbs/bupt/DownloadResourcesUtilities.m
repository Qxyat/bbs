//
//  DownloadResources.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "DownloadResourcesUtilities.h"
#import "LoginManager.h"

#import <SDWebImageDownloader.h>
#import <SDImageCache.h>
#import <YYKit.h>

@implementation DownloadResourcesUtilities

#pragma mark - 下载图片
+(YYImage*)downloadImage:(NSString *)string
                 FromBBS:(BOOL)isFromBBS
               Completed:(void (^)(YYImage *image))block{
    NSString *path=[[SDImageCache sharedImageCache]defaultCachePathForKey:string];
    YYImage *cachedImage=nil;
    cachedImage=[YYImage imageWithContentsOfFile:path];
    if(cachedImage==nil){
        NSURL *url=nil;
        if(isFromBBS){
           url=[NSURL URLWithString:
                        [NSString stringWithFormat:@"%@?oauth_token=%@",string,[LoginManager sharedManager].access_token]];
        }
        else{
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@",string]];
        }
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if(finished&&error==nil){
                YYImage *downloadImage=[YYImage imageWithData:data];
                [[SDImageCache sharedImageCache]storeImage:image recalculateFromImage:NO imageData:data forKey:string toDisk:YES];
                if(block!=nil){
                    block(downloadImage);
                }
            }
        }];
    }
    return cachedImage;
}
@end
