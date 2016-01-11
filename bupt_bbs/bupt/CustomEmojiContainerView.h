//
//  CustomEmojiView.h
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomEmojiKeyboardDelegate.h"
@interface CustomEmojiContainerView : UIView

@property (weak,nonatomic) id<CustomEmojiKeyboardDelegate> delegate;
@property (strong,nonatomic) NSString *imageString;

@end
