//
//  ArticlePreProcessing.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticlePreProcessingUtilities : NSObject

//目前主要用来预加载一页文章所需要的资源，目前是图片和表情资源
+(void)onePageArticlesPreProcess:(NSArray*)array;

@end
