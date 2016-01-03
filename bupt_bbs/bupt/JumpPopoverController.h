//
//  JumpPopoverController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/3.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JumpPopoverControllerDelegate.h"
@interface JumpPopoverController : UIViewController<UITextFieldDelegate>
+(instancetype)getInstance;
-(void)hideJumpPopoverControllerView;
@property(strong,nonatomic)id<JumpPopoverControllerDelegate>delegate;
@property(nonatomic)CGFloat navigationBarHeight;
@property (nonatomic)     int              page_all_count;
@property (nonatomic)     int              page_cur_count;
@end
