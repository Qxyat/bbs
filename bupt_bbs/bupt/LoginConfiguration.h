//
//  LoginConfiguration.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
@interface LoginConfiguration : NSObject<NSCoding>

@property (copy,nonatomic)NSString *access_token;
@property (copy,nonatomic)NSString *refresh_token;
@property (copy,nonatomic)NSString *expires_in;
@property (nonatomic)BOOL shouldSaveLoginConfiguration;
@property (strong,nonatomic)UserInfo *loginUserInfo;

+(instancetype)getInstance;

+(void)saveLoginConfiguration;
+(void)deleteLoginConfiguration;

+(void)saveLoadConfiguration:(NSString*)loadConfiguration saveLoginConfiguration:(BOOL)shouldSaveLoginConfiguration;

@end
