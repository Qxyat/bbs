//
//  DownloadResources.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYImage;
@interface DownloadResourcesUtilities : NSObject

+(YYImage*)getImageFromDisk:(NSString *)string;

+(void)downloadImage:(NSString *)string
                 FromBBS:(BOOL)isFromBBS
               Completed:(void (^)(YYImage *image,BOOL isFailed))block;

@end