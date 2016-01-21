//
//  ScreenAdaptionUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCustomScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define kCustomScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kCustomScreenSize  [UIScreen mainScreen].bounds.size
#define kCustomScreenBounds [UIScreen mainScreen].bounds
#define kCustomNavigationBarHeight CGRectGetHeight(self.navigationController.navigationBar.frame)
#define kCustomStatusBarHeight CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
#define isIPhone6OrIPhone6s kCustomScreenWidth==375&&kCustomScreenHeight==667
#define isIPhone6PlusOrIPhone6sPlus kCustomScreenWidth==414&&kCustomScreenHeight==736

#define kIPhone5TitleLabelFontSize 16
#define kIPhone5BoardLabelFontSize 8
#define kIPhone6TitleLabelFontSize 18
#define kIPhone6BoardLabelFontSize 10
#define kIPhone6PlusTitleLabelFontSize 20
#define kIPhone6PlusBoardLabelFontSize 12



