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
-(void)handleMailInfoSuccessWithResponse:(id)response;
-(void)handleMailInfoErrorWithResponse:(id)response
                             withError:(NSError*)error;


-(void)handleMailForwardSuccessWithResponse:(id)response;
-(void)handleMailForwardErrorWithResponse:(id)response
                                withError:(NSError*)error;


-(void)handleMailDeleteSuccessWithResponse:(id)response;
-(void)handleMailDeleteErrorWithResponse:(id)response
                               withError:(NSError*)error;

@end
