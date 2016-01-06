//
//  PictureInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/6.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureInfo : NSObject

@property (strong,nonatomic)NSString *thumbnail_url;
@property (strong,nonatomic)NSString *original_url;
@property (nonatomic)BOOL isFromBBS;
@end
