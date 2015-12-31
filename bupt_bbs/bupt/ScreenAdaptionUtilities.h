//
//  ScreenAdaptionUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenSize  [UIScreen mainScreen].bounds.size
#define kScreenBounds [UIScreen mainScreen].bounds
#define kNavigationBarHeight self.navigationController.navigationBar.frame.size.height

#define isIPhone6OrIPhone6s kScreenWidth==375&&kScreenHeight==667
#define isIPhone6PlusOrIPhone6sPlus kScreenWidth==414&&kScreenHeight==736

#define kIPhone5TitleLabelFontSize 16
#define kIPhone5BoardLabelFontSize 8
#define kIPhone6TitleLabelFontSize 18
#define kIPhone6BoardLabelFontSize 10
#define kIPhone6PlusTitleLabelFontSize 20
#define kIPhone6PlusBoardLabelFontSize 12

@interface ScreenAdaptionUtilities : NSObject

@end
