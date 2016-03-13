//
//  SectionUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SectionUtilities.h"
#import "BBSConstants.h"
#import "LoginManager.h"
#import "SectionInfo.h"
#import <AFNetworking.h>

@implementation SectionUtilities

#pragma  mark - 获取根分区下的分区列表
+(void)getSections:(id<SectionHttpResponseDelegate>)delegate{
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
+(void)getSpecifiedSectionWithName:(NSString*)name
               isSubSectionRequest:(BOOL)isSubSectionRequest
                          subIndex:(NSUInteger)index
                          delegate:(id<SectionHttpResponseDelegate>)delegate{
    NSString *url=[NSString stringWithFormat:@"%@/section/%@.json",kRequestURL,name];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];

    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
    [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [delegate handleSectionSucessWithResponse:responseObject isSubSectionRequest:isSubSectionRequest subIndex:index];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [delegate handleSectionErrorWithResponse:operation.responseObject withError:error isSubSectionRequest:isSubSectionRequest subIndex:index];
    }];
}

//#pragma mark - 获取分区的子分区列表
//+(void)getSubSectionsWithName:(NSArray*)array delegate:(id<HttpResponseDelegate>)delegate{
//    NSMutableArray *result=[[NSMutableArray alloc]init];
//    NSOperation *last=nil;
//    NSDictionary *dic=@{@"oauth_token":[LoginManager sharedManager].access_token};
//    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
//    manager.responseSerializer=[AFJSONResponseSerializer serializer];
//    for(int i=0;i<array.count;i++){
//        NSString *url=[NSString stringWithFormat:@"%@/section/%@.json",kRequestURL,array[i]];
//        [manager GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            [delegate handleSubSectionSuccessWithResponse:responseObject];
//        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//            NSLog(@"请求子分区出错");
//        }];
//        
//    }
//}
@end
