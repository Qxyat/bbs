//
//  CustomEmojiView.h
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit.h>
#import "QCEmojiKeyboardDelegate.h"

@interface QCEmojiCell : UICollectionViewCell

@property (strong,nonatomic) NSString *imageString;
@property (strong,nonatomic) YYImage *image;

@end
