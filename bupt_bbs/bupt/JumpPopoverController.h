//
//  JumpPopoverController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/3.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JumpPopoverControllerDelegate <NSObject>
-(void)hideJumpPopoverController;
-(void)jumpToRefresh:(NSUInteger) nextPage;
@end

@interface JumpPopoverController : UIViewController

+(instancetype)getInstanceWithFrame:(CGRect)frame
                   withPageAllCount:(NSInteger)page_all_count
                   withPageCurCount:(NSInteger)page_cur_count
                       withDelegate:(id<JumpPopoverControllerDelegate>)delegate;

-(void)hideJumpPopoverControllerView;

@end
