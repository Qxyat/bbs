//
//  PostArticleUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/9.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "PostArticleUtilities.h"
#import "BBSConstants.h"
#import "LoginManager.h"
#import <AFNetworking.h>
@implementation PostArticleUtilities
+(void)postArticleWithBoardName:(NSString*)boardName
               withArticleTitle:(NSString*)articleTitle
             withArticleContent:(NSString*)articleContent
                     isNewTheme:(BOOL)isNewTheme
             withReplyArticleID:(int)replyArticleID
                       delegate:(id<HttpResponseDelegate>)delegate
{
    AFHTTPRequestOperationManager *manaer=[AFHTTPRequestOperationManager manager];
    NSString *url=[NSString stringWithFormat:@"%@/article/%@/post.json",kRequestURL,boardName];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:
  @{@"oauth_token":[LoginManager sharedManager].access_token,
    @"title":articleTitle,
    @"content":articleContent
    }];
    if(!isNewTheme){
        [dic setValue:[NSNumber numberWithInt:replyArticleID] forKey:@"reid"];
    }
    manaer.requestSerializer.timeoutInterval=kRequestTimeout;
    [manaer POST:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpSuccessResponse:nil];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleHttpSuccessResponse:error];
    }];
}

@end
