//
//  MailboxUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailboxUtilities.h"
#import "BBSConstants.h"
#import "LoginManager.h"

#import <AFNetworking.h>

@implementation MailboxUtilities

+(void)getMailsWithMailbox:(NSString*)mailbox
                withPageNO:(NSInteger)pageNO
             withPagecount:(NSInteger)pagecount
              withDelegate:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/mail/%@.json",kRequestURL,mailbox];
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token,
                        @"count":[NSNumber numberWithInteger:pagecount],
                        @"page":[NSNumber numberWithInteger:pageNO]};
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval=kRequestTimeout;
    
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpSuccessResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleHttpErrorResponse:error];
    }];
}

+(void)getMailWithMailbox:(NSString*)mailbox
                withIndex:(NSInteger)index
             withDelegate:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/mail/%@/%ld.json",kRequestURL,mailbox,(long)index];
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval=kRequestTimeout;
    
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpSuccessResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleHttpErrorResponse:error];
    }];
}
@end
