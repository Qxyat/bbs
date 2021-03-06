//
//  MailboxUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
#import "MailHttpResponseDelegate.h"

@interface MailboxUtilities : NSObject

+(void)getMailsWithMailbox:(NSString*)mailbox
                withPageNO:(NSInteger)pageNO
             withPagecount:(NSInteger)pagecount
              withDelegate:(id<HttpResponseDelegate>)delegate;

+(void)getMailWithMailbox:(NSString*)mailbox
                withIndex:(NSInteger)index
             withDelegate:(id<MailHttpResponseDelegate>)delegate;

+(void)postNewMailWithUserId:(NSString *)userId
                   withTitle:(NSString *)title
                 withContent:(NSString *)content
               withSignature:(NSInteger)signature
                  withbackup:(NSInteger)backup
                withDelegate:(id<HttpResponseDelegate>)delegate;

+(void)postReplyMailWithBoxName:(NSString *)box_name
                      withIndex:(NSInteger )index
                      withTitle:(NSString *)title
                    withContent:(NSString *)content
                  withSignature:(NSInteger)signature
                     withbackup:(NSInteger)backup
                   withDelegate:(id<HttpResponseDelegate>)delegate;

+(void)forwardMailWithBoxName:(NSString*)box_name
                    withIndex:(NSInteger)index
                   withTarget:(NSString*)userId
                   withNoansi:(NSInteger)noansi
                     withBig5:(NSInteger)big5
                 withDelegate:(id<MailHttpResponseDelegate>)delegate;

+(void)deleteMailWithBoxName:(NSString*)box_name
                   withIndex:(NSInteger)index
                withDelegate:(id<MailHttpResponseDelegate>)delegate;
@end
