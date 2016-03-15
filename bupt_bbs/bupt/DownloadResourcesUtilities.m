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
#import <AFNetworking.h>
#import <YYKit.h>

@implementation DownloadResourcesUtilities

#pragma mark - 获取已下载过的图片
+(YYImage*)getDownloadedImage:(NSString *)string{
    NSString *path=[[SDImageCache sharedImageCache]defaultCachePathForKey:string];

    return [YYImage imageWithContentsOfFile:path];
}
#pragma mark - 下载图片
+(YYImage*)downloadImage:(NSString *)string
                 FromBBS:(BOOL)isFromBBS
               Completed:(void (^)(YYImage *image,BOOL isFailed))block{
    NSString *path=[[SDImageCache sharedImageCache]defaultCachePathForKey:string];
    YYImage *cachedImage=nil;
    cachedImage=[YYImage imageWithContentsOfFile:path];
    if(cachedImage==nil){
        NSURL *url=nil;
        NSString *urlString=nil;
        if(isFromBBS){
           urlString=[NSString stringWithFormat:@"%@?oauth_token=%@",string,[LoginManager sharedManager].access_token];
           url=[NSURL URLWithString:
                        [NSString stringWithFormat:@"%@?oauth_token=%@",string,[LoginManager sharedManager].access_token]];
        }
        else{
            urlString=[NSString stringWithFormat:@"%@",string];
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@",string]];
        }
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer=[AFHTTPResponseSerializer serializer];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            YYImage *downloadImage=[YYImage imageWithData:responseObject];
            [[SDImageCache sharedImageCache]storeImage:downloadImage recalculateFromImage:NO imageData:responseObject forKey:string toDisk:YES];
            
            if(block!=nil){
                block(downloadImage,false);
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if(block!=nil){
                block(nil,true);
            }
        }];
    }
    return cachedImage;
}
@end
