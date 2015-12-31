//
//  BoardArticleInfoCellTableViewCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BoardArticleInfoCell.h"
#import "ScreenAdaptionUtilities.h"

@implementation BoardArticleInfoCell

-(void)awakeFromNib{
    CGFloat margin=0.05*kScreenWidth;
    UIEdgeInsets edge=UIEdgeInsetsMake(0, margin, 0, margin);
    [self setSeparatorInset:edge];
}

@end
