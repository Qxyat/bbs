//
//  SectionUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SectionUtilities.h"
#import "BBSConstants.h"
#import <AFNetworking.h>
#import "LoginManager.h"
#import "SectionInfo.h"
@implementation SectionUtilities

#pragma  mark - 获取根分区下的分区列表
+(void)getSections:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/section.json",kRequestURL];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpSuccessWithResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleHttpErrorWithResponse:operation.responseObject withError:error];
    }];
}

#pragma mark - 获取指定分区下的分区列表
+(void)getSpecifiedSectionsWithName:(NSString*)name delegate:(id<HttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/section/%@.json",kRequestURL,name];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleHttpSuccessWithResponse:responseObject];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleHttpErrorWithResponse:operation.responseObject withError:error];
    }];
}

#pragma mark - 获取分区的子分区列表
+(void)getSubSectionsWithName:(NSArray*)array delegate:(id<HttpResponseDelegate>)delegate{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    NSOperation *last=nil;
    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    for(int i=0;i<array.count;i++){
        NSString *url=[NSString stringWithFormat:@"%@/section/%@.json",kRequestURL,array[i]];
        NSMutableURLRequest *request=[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:dic error:nil];
        AFHTTPRequestOperation *opearation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
        [opearation setResponseSerializer:[AFJSONResponseSerializer serializer]];
        if(i!=array.count-1){
            [opearation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                [result addObject:[SectionInfo getSectionInfo:responseObject]];
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSLog(@"请求子分区列表出错");
            }];
        }
        else{
            [opearation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                [result addObject:[SectionInfo getSectionInfo:responseObject]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate handleSubSectionResponse:result];
                });
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSLog(@"请求子分区列表出错");
            }];
        }
        if(last!=nil){
            [opearation addDependency:last];
            last=opearation;
        }
        [queue addOperation:opearation];
    }
}
@end
