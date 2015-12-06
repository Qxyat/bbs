//
//  AttachmentInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentInfo : NSObject

@property (copy,nonatomic)    NSArray  *file;
@property (strong,nonatomic)  NSString *remain_space;
@property (nonatomic)  int remain_count;

+(AttachmentInfo*)getAttachmentInfo:(id)item;
@end
