//
//  GetArticleInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ArticleInfoDelegate <NSObject>

@optional
-(void)fillArticlesInfo:(NSArray*)array;
-(void)fillArticleInfo:(NSDictionary*)dic;

@end
