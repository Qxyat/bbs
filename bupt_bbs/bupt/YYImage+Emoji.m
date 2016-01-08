//
//  UIImage+Emoji.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/7.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "YYImage+Emoji.h"

@implementation YYImage (Emoji)
+(YYImage*)imageNamedFromEmojiBundle:(NSString*)imageName{
    NSString *bundlePath=[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Emoji.bundle"];
    NSBundle *bundle=[NSBundle bundleWithPath:bundlePath];
    return [YYImage imageWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:imageName ofType:@"gif"]]];
}
@end
