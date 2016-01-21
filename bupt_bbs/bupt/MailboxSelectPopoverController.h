//
//  MailboxSelectPopoverController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MailboxSelectPopoverControllerDelegate <NSObject>

-(void)hideMailboxSelectPopoverController;
-(void)disSelectItemAtIndex:(NSInteger)pos;

@end

@interface MailboxSelectPopoverController : UIViewController

@property (nonatomic)CGFloat navigationBarHeight;
@property (weak,nonatomic)id<MailboxSelectPopoverControllerDelegate>delegate;
+(instancetype)getInstance;
-(void)hideMailboxSelectView;

@end
