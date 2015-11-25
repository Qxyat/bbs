//
//  LoginUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUtilities : NSObject

+(void)doLogin:(NSString*)userName password:(NSString*)password saveUserInfo:(BOOL)shouldSave;

@end
