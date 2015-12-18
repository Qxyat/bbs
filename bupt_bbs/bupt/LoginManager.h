//
//  LoginConfiguration.h
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
@interface LoginManager : NSObject<NSCoding>

@property (copy,nonatomic)NSString *access_token;
@property (copy,nonatomic)NSString *refresh_token;
@property (copy,nonatomic)NSString *expires_in;
@property (copy,nonatomic)UserInfo *currentLoginUserInfo;
@property (strong,nonatomic)NSMutableArray * loginUserHistory;

+(instancetype)sharedManager;

-(void)deleteLoginConfiguration;

-(void)saveLoginConfiguration:(NSString*)loadConfiguration
        shouldPersistentStore:(BOOL)shouldPersistentStore;

@end
