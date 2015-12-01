//
//  LoginUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface LoginUtilities : NSObject

+(void)doLogin:(NSString*)userName password:(NSString*)password saveLoginConfiguration:(BOOL)shouldSave delegate:(LoginViewController *)viewController;

@end
