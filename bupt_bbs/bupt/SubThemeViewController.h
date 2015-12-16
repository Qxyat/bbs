//
//  SubThemeViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/10.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeViewController.h"

@interface SubThemeViewController : UIViewController

@property (nonatomic) int page_all_count;
@property (weak,nonatomic) ThemeViewController *themViewController;
+(SubThemeViewController *)getInstance;

@end
