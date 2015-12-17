//
//  FirstLoginViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginHttpResponseDelegate.h"

@interface FirstLoginViewController : UIViewController<UITextFieldDelegate,LoginHttpResponseDelegate>

+(FirstLoginViewController*)getInstance;

@end
