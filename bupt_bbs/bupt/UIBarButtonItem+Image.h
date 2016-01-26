//
//  UIBarButtonItem+Image.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/26.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Image)

+(instancetype)getInstanceWithNormalImage:(UIImage *)normarlImage
                     withHighlightedImage:(UIImage *)highlightedImage
                                   target:(id)target
                                   action:(SEL)selector;

@end
