//
//  BoardUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BoardUtilities.h"
#import "HttpResponseDelegate.h"
#import "BBSConstants.h"
#import "LoginManager.h"
#import <AFNetworking.h>

@implementation BoardUtilities

+(void)getBoardWithName:(NSString*)name
                   Mode:(int)mode
                  Count:(int)count
                   Page:(int)page
               Delegate:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/board/%@.json",kRequestURL,name];
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token,
                        @"mode":[NSNumber numberWithInt:mode],
                        @"count":[NSNumber numberWithInt:count],
                        @"page":[NSNumber numberWithInt:page]};
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"请求版面失败");
    }];
}

@end
