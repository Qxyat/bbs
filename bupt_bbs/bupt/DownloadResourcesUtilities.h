//
//  DownloadResources.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadResourcesUtilities : NSObject

+(void)downLoadEmoji:(NSString *)string
           Completed:(void(^)())block;
+(void)downloadPicture:(NSString*)string
               FromBBS:(BOOL)isFromBBS
             Completed:(void(^)())block;

@end