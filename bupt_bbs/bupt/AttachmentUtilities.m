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
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager POST:requestURL parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:fileType];
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(delegate!=nil)
            [delegate handlePostAttachmentSuccessResponse:responseObject withData:fileData withName:fileName];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if(delegate!=nil)
            [delegate handlePostAttachmentErrorResponse:
                               operation.responseObject
                      withError:error];
    }];
}

+(void)deleteAttachmentWithBoardName:(NSString *)boardName
                 withNeedArticleID:(BOOL)needArticleID
                     withArticleID:(int)articleID
                      withFileName:(NSString*)fileName
                           withPos:(NSInteger)pos
                            delegate:(id<AttachmentHttpResponseDelegate>)delegate{
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token,@"name":fileName
                        };
    NSString *requestURL;
    if(needArticleID){
        requestURL=[NSString stringWithFormat:@"%@/attachment/%@/delete/%d.json",kRequestURL,boardName,articleID];
    }
    else{
        requestURL=[NSString stringWithFormat:@"%@/attachment/%@/delete.json",kRequestURL,boardName];
    }
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager POST:requestURL parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(delegate!=nil)
            [delegate handleDeleteAttachmentSuccessResponse:responseObject withPos:pos];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if(delegate!=nil)
            [delegate handleDeleteAttachmentErrorResponse:
                               operation.responseObject
                  withError:error];
    }];
}
@end
