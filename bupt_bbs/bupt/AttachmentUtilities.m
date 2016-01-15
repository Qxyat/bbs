//
//  AttachmentUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/15.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "AttachmentUtilities.h"
#import "LoginManager.h"
#import "BBSConstants.h"

#import <AFNetworking.h>

@implementation AttachmentUtilities

+(void)getAttachmentInfoWithBoardName:(NSString *)boardName
                    withNeedArticleID:(BOOL)needArticleID
                        withArticleID:(int)articleID
                             delegate:(id<AttachmentHttpResponseDelegate>)delegate{
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token
                        };
    NSString *requestURL;
    if(needArticleID){
        requestURL=[NSString stringWithFormat:@"%@/attachment/%@/%d.json",kRequestURL,boardName,articleID];
    }
    else{
        requestURL=[NSString stringWithFormat:@"%@/attachment/%@.json",kRequestURL,boardName];
    }
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval=kRequestTimeout;
    [manager GET:requestURL parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(delegate!=nil){
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if(delegate!=nil){
        }
    }];
}


+(void)postAttachmentWithBoardName:(NSString *)boardName
              withNeedArticleID:(BOOL)needArticleID
                     withArticleID:(int)articleID
                      withFileName:(NSString*)fileName
                      withFileType:(NSString*)fileType
                      withFileData:(NSData*)fileData
                          delegate:(id<AttachmentHttpResponseDelegate>)delegate{
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token
                        };
    NSString *requestURL;
    if(needArticleID){
        requestURL=[NSString stringWithFormat:@"%@/attachment/%@/add/%d.json",kRequestURL,boardName,articleID];
    }
    else{
        requestURL=[NSString stringWithFormat:@"%@/attachment/%@/add.json",kRequestURL,boardName];
    }
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval=kRequestTimeout;
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager POST:requestURL parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:fileType];
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@ %@",responseObject[@"code"],responseObject[@"msg"]);
        if(delegate!=nil)
            [delegate handlePostAttachmentSuccessResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        NSDictionary *dic=error.userInfo[@"com.alamofire.serialization.response.error.data"];
//        NSLog(@"%@",error.userInfo[@"com.alamofire.serialization.response.error.data"]);
        if(delegate!=nil)
            [delegate handlePostAttachmentErrorResponse:error];
    }];
}
@end
