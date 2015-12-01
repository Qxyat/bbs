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
#import "LoginConfiguration.h"
#import "LoginViewController.h"

@implementation LoginUtilities
+(void)doLogin:(NSString*)username password:(NSString*)password saveLoginConfiguration:(BOOL)shouldSaveLoginConfiguration delegate:(LoginViewController *)viewController{
    NSDictionary *dic=@{@"client_id":kAppKey,
                        @"response_type":@"token",
                        @"redirect_uri":kRedirectURL,
                        @"state":@"35f7879b051b0bcb77a015977f5aeeeb",
                        @"scope":@"/",
                        @"username":username,
                        @"password":password};
    NSMutableURLRequest *request=
    [[AFHTTPRequestSerializer serializer]requestWithMethod:@"POST" URLString:@"http://bbs.byr.cn/oauth2/authorize/finishClientAuth" parameters:dic error:nil];
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setRedirectResponseBlock:^NSURLRequest * _Nonnull(NSURLConnection * _Nonnull connection, NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull redirectResponse) {
        if(redirectResponse!=nil){
            NSHTTPURLResponse *response=(NSHTTPURLResponse*)redirectResponse;
            NSDictionary *dic=[response allHeaderFields];
            NSString *location=dic[@"Location"];
            NSArray* array=[location componentsSeparatedByString:@"#"];
            if([array count]>1){
                [LoginConfiguration saveLoadConfiguration:array[1] saveLoginConfiguration:shouldSaveLoginConfiguration];
               
                dispatch_async(dispatch_get_main_queue(), ^{
                     [viewController showHome];
                });
            }
           
            return nil;
        }
        return request;
    }];
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}
@end