//
//  AttachmentUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/15.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentHttpResponseDelegate.h"
@interface AttachmentUtilities : NSObject
+(void)getAttachmentInfoWithBoardName:(NSString *)boardName
                    withNeedArticleID:(BOOL)needArticleID
                        withArticleID:(int)articleID
                             delegate:(id<AttachmentHttpResponseDelegate>)delegate;

+(void)postAttachmentWithBoardName:(NSString *)boardName
                 withNeedArticleID:(BOOL)needArticleID
                     withArticleID:(int)articleID
                      withFileName:(NSString*)fileName
                      withFileType:(NSString*)fileType
                      withFileData:(NSData*)fileData
                          delegate:(id<AttachmentHttpResponseDelegate>)delegate;

@end
