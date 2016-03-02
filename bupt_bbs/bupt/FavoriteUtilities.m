//
//  FavoriteUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 16/3/1.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "FavoriteUtilities.h"
#import "BBSConstants.h"
#import "LoginManager.h"

#import <AFNetworking.h>
@implementation FavoriteUtilities

+(void)getFavoriteInfoWithLevel:(NSUInteger)level
                   withDelegate:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/favorite/%d.json",kRequestURL,level];
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    
    AFHTTPRequestSerializer *requestSerializer=[AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval=kRequestTimeout;
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.requestSerializer=requestSerializer;
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(delegate!=nil){
            [delegate handleHttpSuccessResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if(delegate!=nil){
            [delegate handleHttpErrorResponse:error];
        }
    }];
}

@end
