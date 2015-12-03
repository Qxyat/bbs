//
//  FileInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileInfo : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSString *size;
@property (strong,nonatomic) NSString *thumbnail_small;
@property (strong,nonatomic) NSString *thumbnail_middle;

@end
