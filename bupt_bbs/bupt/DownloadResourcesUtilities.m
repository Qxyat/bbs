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

@implementation DownloadResourcesUtilities

#pragma mark - 根据表情代码获取表情对应的Attributed String
+(void)downLoadEmoji:(NSString *)string
           Completed:(void(^)())block{
    NSRange range =[string rangeOfString:@"^[a-zA-z]+" options:NSRegularExpressionSearch];
    NSString* url=[NSString stringWithFormat:@"%@/%@/%@.gif",@"http://bbs.byr.cn/img/ubb",[string substringWithRange:range],[string substringFromIndex:range.location+range.length]];
    
    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [[SDImageCache sharedImageCache] storeImage:image forKey:url toDisk:YES];
        if(block!=nil)
            block();
    }];
}
#pragma mark - 下载图片
+(void)downloadPicture:(NSString *)string
               FromBBS:(BOOL)isFromBBS
             Completed:(void (^)(UIImage *image,NSData *data))block{
    if(![[SDImageCache sharedImageCache]diskImageExistsWithKey:string]){
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
                [[SDImageCache sharedImageCache]storeImage:image recalculateFromImage:NO imageData:data forKey:string toDisk:YES];
                if(block!=nil){
                    block(image,data);
                }
            }
        }];
    }
}
@end
