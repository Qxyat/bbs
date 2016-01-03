//
//  HomeViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UITabBarControllerDelegate>

+(instancetype)getInstance;
-(void)showLeft;
@end
