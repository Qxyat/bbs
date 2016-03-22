//
//  PictureInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/6.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,PictureState){
    PictureIsIdle,
    PictureIsDownloading,
    PictureIsDownloaded,
    PictureIsFailed
};

@interface PictureInfo : NSObject

@property (nonatomic,readwrite,copy)NSString *thumbnail_url;
@property (nonatomic,readwrite,copy)NSString *original_url;
@property (nonatomic,readwrite,assign)BOOL isFromBBS;
@property (nonatomic,readwrite,assign)PictureState pictureState;
@property (nonatomic,readwrite,assign)BOOL isShowed;
@property (nonatomic,readwrite,strong) UIImage *image;

@end
