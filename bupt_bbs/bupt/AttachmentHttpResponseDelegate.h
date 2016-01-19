//
//  AttachmentHttpResponseDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/15.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AttachmentHttpResponseDelegate <NSObject>

-(void)handlePostAttachmentSuccessResponse:(id)response
                                  withData:(NSData*)data
                                  withName:(NSString*)name;

-(void)handlePostAttachmentErrorResponse:(id)response
                               withError:(NSError*)error;

-(void)handleDeleteAttachmentSuccessResponse:(id)response
                                     withPos:(NSInteger)pos;

-(void)handleDeleteAttachmentErrorResponse:(id)response
                                 withError:(NSError*)error;

@end
