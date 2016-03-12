//
//  AttachmentHttpResponseDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/15.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AttachmentHttpResponseDelegate <NSObject>

-(void)handlePostAttachmentSuccessWithResponse:(id)response
                                  withData:(NSData*)data
                                  withName:(NSString*)name;

-(void)handlePostAttachmentErrorWithResponse:(id)response
                               withError:(NSError*)error;

-(void)handleDeleteAttachmentSuccessWithResponse:(id)response
                                     withPos:(NSInteger)pos;

-(void)handleDeleteAttachmentErrorWithResponse:(id)response
                                 withError:(NSError*)error;

@end
