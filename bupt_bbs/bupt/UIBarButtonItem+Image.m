//
//  UIBarButtonItem+Image.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/26.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "UIBarButtonItem+Image.h"

@implementation UIBarButtonItem (Image)

+(instancetype)getInstanceWithNormalImage:(UIImage *)normarlImage
              withHighlightedImage:(UIImage *)highlightedImage
                            target:(id)target
                            action:(SEL)selector{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:normarlImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.frame=CGRectMake(0, 0,28, 28);
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    return barButtonItem;
}

@end
