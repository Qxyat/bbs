//
//  AttachmentFile.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/6.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentFile : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSString *size;
@property (strong,nonatomic) NSString *thumbnail_small;
@property (strong,nonatomic) NSString *thumbnail_middle;

+(NSArray*)getAttachmentFiles:(id)item;
+(AttachmentFile *)getAttachmentFile:(id)item;
@end
