//
//  ThemeUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ThemeUtilities.h"
#import "BBSConstants.h"
#import "LoginConfiguration.h"
#import <AFNetworking.h>

@implementation ThemeUtilities

+(void)getThemeWithBoardName:(NSString*)board_name groupId:(int)group_id
                   pageIndex:(int)page countOfOnePage:(int)count
                    delegate:(id<HttpResponseDelegate>)delegate
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    NSString *requestUrl=[NSString stringWithFormat:@"%@/threads/%@/%d.json",kRequestURL,board_name,group_id];
    
    LoginConfiguration *loginConfiguration=[LoginConfiguration getInstance];
    NSDictionary *parameters=@{@"oauth_token":loginConfiguration.access_token,
                               @"page":[NSNumber numberWithInt:page],
                               @"count":[NSNumber numberWithInt:count]};
    
    manager.responseSerializer=[[AFJSONResponseSerializer alloc]init];
    
    [manager GET:requestUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}

@end
