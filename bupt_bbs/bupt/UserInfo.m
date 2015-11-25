//
//  UserInfo.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UserInfo.h"
static NSString *const kUserInfoKey=@"userinfo";
static NSString *const kAccessTokenKey=@"access_token";
static NSString *const kRefreshTokenKey=@"refresh_token";
static NSString *const kExpireInKey=@"expires_in";


static UserInfo * user=nil;
static dispatch_once_t token;

static NSString * userDataFilePath(){
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"user.archive"];
}

@implementation UserInfo

#pragma mark - 实现NSCoding协议
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.access_token forKey:kAccessTokenKey];
    [aCoder encodeObject:self.refresh_token forKey:kRefreshTokenKey];
    [aCoder encodeObject:self.expires_in forKey:kExpireInKey];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super init]){
        self.access_token=[aDecoder decodeObjectForKey:kAccessTokenKey];
        self.refresh_token=[aDecoder decodeObjectForKey:kRefreshTokenKey];
        self.expires_in=[aDecoder decodeObjectForKey:kExpireInKey];
    }
    return self;
}

#pragma mark - 获得UserInfo的单例
+(instancetype)getInstance{
    dispatch_once(&token, ^{
        NSData *data=[[NSData alloc]initWithContentsOfFile:userDataFilePath()];
        if(data==nil){
            user=[[UserInfo alloc]init];
        }
        else{
            NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            user=[unarchiver decodeObjectForKey:kUserInfoKey];
            [unarchiver finishDecoding];
        }
    });
    return user;
}

#pragma mark - 保存UserInfo
+(void)saveUserInfo{
    if(user.shouldSaveUserInfo){
        NSMutableData *data=[[NSMutableData alloc]init];
        NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:user forKey:kUserInfoKey];
        [archiver finishEncoding];
        [data writeToFile:userDataFilePath() atomically:YES];
    }
    else{
        [UserInfo deleteUserInfo];
    }
}
#pragma mark - 删除UserInfo
+(void)deleteUserInfo{
    user=[[UserInfo alloc]init];
    [[NSFileManager defaultManager] removeItemAtPath:userDataFilePath() error:nil];
}

#pragma mark - 保存用户的access_token,refresh_token,expires_in
+(void)saveLoadConfiguration:(NSString *)loadConfiguration saveUserInfo:(BOOL)shouldSaveUserInfo{
    user.shouldSaveUserInfo=shouldSaveUserInfo;
    NSArray *tuples=[loadConfiguration componentsSeparatedByString:@"&"];
    for(NSString *tuple in tuples){
        NSArray *pairs=[tuple componentsSeparatedByString:@"="];
        if([pairs[0] isEqualToString:@"access_token"]){
            user.access_token=pairs[1];
        }
        else if([pairs[0] isEqualToString:@"expires_in"]){
            user.expires_in=pairs[1];
        }
        else if([pairs[0] isEqualToString:@"refresh_token"]){
            user.refresh_token=pairs[1];
        }
    }
    
}
@end
