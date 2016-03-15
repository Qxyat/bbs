//
//  PictureInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/6.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureInfo : NSObject

@property (strong,nonatomic)NSString *thumbnail_url;
@property (strong,nonatomic)NSString *original_url;
@property (nonatomic)BOOL isFromBBS;
@property (nonatomic)BOOL isDownloading;
@property (nonatomic)BOOL isDownloaded;
@property (nonatomic)BOOL isFailed;
@property (nonatomic)BOOL isShowed;
@property (nonatomic,strong) UIImage *image;

@end
