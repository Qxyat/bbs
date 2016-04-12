//
//  ShowUserInfoViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoViewControllerDelegate <NSObject>

-(void)hideUserInfoViewController;

@end

@class UserInfo;

@interface UserInfoViewController : UIViewController

+(instancetype)getInstanceWithUserInfo:(UserInfo *)userInfo
                              Delegate:(id<UserInfoViewControllerDelegate>)delegate;

-(void)hideUserInfoControllerView;

@end
