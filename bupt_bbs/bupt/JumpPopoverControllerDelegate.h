//
//  JumpPopoverControllerDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/3.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JumpPopoverControllerDelegate <NSObject>
-(void)hideJumpPopoverController;
-(void)jumpToRefresh:(NSUInteger) nextPage;
@end
