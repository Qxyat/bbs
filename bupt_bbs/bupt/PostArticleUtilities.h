//
//  PostArticleUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/9.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface PostArticleUtilities: NSObject

+(void)postArticleWithBoardName:(NSString*)boardName
               withArticleTitle:(NSString*)articleTitle
             withArticleContent:(NSString*)articleContent
                     isNewTheme:(BOOL)isNewTheme
             withReplyArticleID:(int)replyArticleID
                       delegate:(id<HttpResponseDelegate>)
                                delegate;
@end
