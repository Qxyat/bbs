//
//  MailHttpResponseDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/27.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MailHttpResponseDelegate <NSObject>

@optional
-(void)handleMailInfoSuccessResponse:(id)response;
-(void)handleMailInfoErrorResponseWithError:(NSError*)error
                               withResponse:(id)response;

-(void)handleMailForwardSuccessResponse:(id)response;
-(void)handleMailForwardErrorResponseWithError:(NSError*)error
                               withResponse:(id)response;

-(void)handleMailDeleteSuccessResponse:(id)response;
-(void)handleMailDeleteErrorResponseWithError:(NSError*)error
                                  withResponse:(id)response;
@end
