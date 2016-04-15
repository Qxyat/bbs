//
//  UserMainInterfaceViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/2/29.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMainInterfaceViewController : UITabBarController

+(instancetype)getInstance;

@property (nonatomic,strong,readwrite)NSMutableArray* navigationControllers;

@end
