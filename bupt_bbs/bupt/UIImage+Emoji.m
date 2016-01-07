//
//  UIImage+Emoji.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/7.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "UIImage+Emoji.h"
#import <UIImage+GIF.h>

@implementation UIImage (Emoji)
+(UIImage*)imageNamedFromEmojiBundle:(NSString*)imageName{
    NSString *bundlePath=[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Emoji.bundle"];
    NSBundle *bundle=[NSBundle bundleWithPath:bundlePath];
    return [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:imageName ofType:@"gif"]]];
}
@end
