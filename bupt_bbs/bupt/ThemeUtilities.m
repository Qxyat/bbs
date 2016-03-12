//
//  ThemeUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ThemeUtilities.h"
#import "BBSConstants.h"
#import "LoginManager.h"
#import <AFNetworking.h>

@implementation ThemeUtilities

+(void)getThemeWithBoardName:(NSString*)board_name groupId:(int)group_id
                   pageIndex:(int)page countOfOnePage:(int)count
                    delegate:(id<HttpResponseDelegate>)delegate
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    NSString *requestUrl=[NSString stringWithFormat:@"%@/threads/%@/%d.json",kRequestURL,board_name,group_id];
    
    LoginManager *loginConfiguration=[LoginManager sharedManager];
    NSDictionary *parameters=@{@"oauth_token":loginConfiguration.access_token,
                               @"page":[NSNumber numberWithInt:page],
                               @"count":[NSNumber numberWithInt:count]};
    
    manager.requestSerializer.timeoutInterval=kRequestTimeout;
    manager.responseSerializer=[[AFJSONResponseSerializer alloc]init];
    
    [manager GET:requestUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpSuccessWithResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleHttpErrorWithResponse:operation.responseObject
         withError:error];
    }];

}

@end
