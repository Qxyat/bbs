//
//  ShowUserInfoViewControllerDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ShowUserInfoViewController;

@protocol ShowUserInfoViewControllerDelegate <NSObject>

-(void)userInfoViewControllerDidDismiss:(ShowUserInfoViewController*)showUserInfoViewController;

@end
