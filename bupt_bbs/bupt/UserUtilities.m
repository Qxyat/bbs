//
//  UserUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UserUtilities.h"
#import "LoginManager.h"
#import <AFNetworking.h>
#import "BBSConstants.h"

@implementation UserUtilities

+(void)getLoginUserInfo:(id<UserHttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/user/getinfo.json",kRequestURL];
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval=kRequestTimeout;
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleUserInfoSuccessWithResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleUserInfoErrorWithResponse:operation.responseObject withError:error];
    }];
}

@end
