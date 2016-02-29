//
//  HomeViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowUserInfoViewControllerDelegate.h"

@interface UserCenterViewController : UIViewController<ShowUserInfoViewControllerDelegate>

+(instancetype)getInstance;

@end
