//
//  ShowUserInfoViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShowUserInfoViewControllerDelegate.h"

@class UserInfo;

@interface ShowUserInfoViewController : UIViewController

@property (strong,nonatomic)UserInfo *userInfo;
@property (strong,nonatomic)id<ShowUserInfoViewControllerDelegate>delegate;

+(instancetype)getInstance:(id<ShowUserInfoViewControllerDelegate>)delegate;
-(void)showUserInfoView;
-(void)hideUserInfoView;

@end
