//
//  MailboxUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseDelegate.h"
@interface MailboxUtilities : NSObject

+(void)getMailsWithMailbox:(NSString*)mailbox
                withPageNO:(NSInteger)pageNO
             withPagecount:(NSInteger)pagecount
              withDelegate:(id<HttpResponseDelegate>)delegate;
@end
