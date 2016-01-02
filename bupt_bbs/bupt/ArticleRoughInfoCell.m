//
//  ArticleRoughInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/28.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ArticleRoughInfoCell.h"
#import "ScreenAdaptionUtilities.h"
@implementation ArticleRoughInfoCell

-(void)awakeFromNib{
    CGFloat margin=0.05*kCustomScreenWidth;
    UIEdgeInsets edge=UIEdgeInsetsMake(0, margin, 0, margin);
    [self setSeparatorInset:edge];
}

@end
