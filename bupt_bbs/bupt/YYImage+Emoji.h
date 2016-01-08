//
//  UIImage+Emoji.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/7.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit.h>

@interface YYImage (Emoji)
+(YYImage*)imageNamedFromEmojiBundle:(NSString*)imageName;
@end
