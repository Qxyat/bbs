//
//  RecommedUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/14.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "RecommedUtilities.h"
#import "HttpResponseDelegate.h"
#import "BBSConstants.h"
#import <AFNetworking.h>
#import "LoginManager.h"

@implementation RecommedUtilities

+(void)getRecommendArticles:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/widget/recommend.json",kRequestURL];
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
