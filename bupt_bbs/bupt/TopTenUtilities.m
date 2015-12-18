//
//  TopTenUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/1.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "TopTenUtilities.h"
#import "BBSConstants.h"
#import "LoginManager.h"
#import <AFNetworking.h>
#import "ArticleInfo.h"
@implementation TopTenUtilities


+(void)getTopTenArticles:(id<HttpResponseDelegate>) delegate{
    NSString *url=[kRequestURL stringByAppendingString:@"/widget/topten.json"];
    
    LoginManager *loginConfiguration=[LoginManager sharedManager];
    NSDictionary *paramters=@{@"oauth_token":loginConfiguration.access_token};
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[[AFJSONResponseSerializer alloc]init];
    
    [[AFHTTPRequestOperationManager manager]GET:url parameters:paramters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

@end
