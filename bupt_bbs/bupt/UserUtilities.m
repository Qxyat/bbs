//
//  UserUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UserUtilities.h"
#import "HttpResponseDelegate.h"
#import "LoginConfiguration.h"
#import <AFNetworking.h>
#import "BBSConstants.h"

@implementation UserUtilities

+(void)getLoginUserInfo:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/user/getinfo.json",kRequestURL];
    NSDictionary *dic=@{@"oauth_token":[LoginConfiguration getInstance].access_token};
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleUserInfoResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"获取登陆用户信息失败");
    }];
}

@end
