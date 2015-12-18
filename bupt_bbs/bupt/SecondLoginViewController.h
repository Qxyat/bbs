//
//  LogInViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserHttpResponseDelegate.h"
#import "LoginHttpResponseDelegate.h"

@interface SecondLoginViewController : UIViewController<UITextFieldDelegate,LoginHttpResponseDelegate>

+(SecondLoginViewController *)getInstance;

@end
