//
//  UserInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<NSCoding>

@property (copy,nonatomic)NSString *access_token;
@property (copy,nonatomic)NSString *refresh_token;
@property (copy,nonatomic)NSString *expires_in;
@property (nonatomic)BOOL shouldSaveUserInfo;

+(instancetype)getInstance;

+(void)saveUserInfo;
+(void)deleteUserInfo;

+(void)saveLoadConfiguration:(NSString*)loadConfiguration saveUserInfo:(BOOL)shouldSaveUserInfo;

@end
