//
//  ShowUserInfoViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
@interface ShowUserInfoViewController : UIViewController

@property (strong,nonatomic)UserInfo *userInfo;

+(ShowUserInfoViewController *)getInstance;
-(void)showUserInfoView;

@end
