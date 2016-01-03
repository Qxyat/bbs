//
//  ThemePopoverController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/3.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemePopoverControllerDelegate.h"
@interface ThemePopoverController : UIViewController

@property (weak,nonatomic)id<ThemePopoverControllerDelegate>delegate;

+(instancetype)getInstance;
-(void)hideThemePopoverControllerView;

@end
