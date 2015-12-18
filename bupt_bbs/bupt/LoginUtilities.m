//
//  LoginUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "LoginUtilities.h"
#import "BBSConstants.h"
#import <AFNetworking.h>
#import "LoginManager.h"
#import "SecondLoginViewController.h"

@implementation LoginUtilities

+(void)loginWithUserName:(NSString*)username
                password:(NSString*)password
                delegete:(id<LoginHttpResponseDelegate>)delegate{
    NSDictionary *dic=@{@"client_id":kAppKey,
                        @"response_type":@"token",
                        @"redirect_uri":kRedirectURL,
                        @"state":@"35f7879b051b0bcb77a015977f5aeeeb",
                        @"scope":@"/",
                        @"username":username,
                        @"password":password};
    AFHTTPRequestSerializer *serializer=[AFHTTPRequestSerializer serializer];
    serializer.timeoutInterval=10;
    NSMutableURLRequest *request=
    [serializer requestWithMethod:@"POST" URLString:@"http://bbs.byr.cn/oauth2/authorize/finishClientAuth" parameters:dic error:nil];
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [operation setRedirectResponseBlock:^NSURLRequest * _Nonnull(NSURLConnection * _Nonnull connection, NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull redirectResponse) {
        if(redirectResponse!=nil){
            NSHTTPURLResponse *response=(NSHTTPURLResponse*)redirectResponse;
            NSDictionary *dic=[response allHeaderFields];
            NSString *location=dic[@"Location"];
            NSArray* array=[location componentsSeparatedByString:@"#"];
            if([array count]>1){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate handleLoginSuccessResponse:array[1]];
                });
            }
            return nil;
        }
        return request;
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate handleLoginErrorResponse:responseObject];
        });
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if([error.userInfo[@"NSLocalizedDescription"] containsString:@"302"]){
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate handleLoginRealErrorResponse:error];
            });
        }
    }];
    
    [operation start];
}
@end
