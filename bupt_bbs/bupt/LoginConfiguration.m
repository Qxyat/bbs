//
//  LoginConfiguration.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "LoginConfiguration.h"
static NSString *const kLoginConfigurationKey=@"LoginConfiguration";
static NSString *const kAccessTokenKey=@"access_token";
static NSString *const kRefreshTokenKey=@"refresh_token";
static NSString *const kExpireInKey=@"expires_in";


static LoginConfiguration * loginConfiguration=nil;
static dispatch_once_t token;

static NSString * loginConfigurationFilePath(){
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"loginconfiguration.archive"];
}

@implementation LoginConfiguration

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

#pragma mark - 获得LoginConfiguration的单例
+(instancetype)getInstance{
    dispatch_once(&token, ^{
        NSData *data=[[NSData alloc]initWithContentsOfFile:loginConfigurationFilePath()];
        if(data==nil){
            loginConfiguration=[[LoginConfiguration alloc]init];
        }
        else{
            NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            loginConfiguration=[unarchiver decodeObjectForKey:kLoginConfigurationKey];
            [unarchiver finishDecoding];
        }
    });
    return loginConfiguration;
}

#pragma mark - 保存LoginConfiguration
+(void)saveLoginConfiguration{
    if(loginConfiguration.shouldSaveLoginConfiguration){
        NSMutableData *data=[[NSMutableData alloc]init];
        NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:loginConfiguration forKey:kLoginConfigurationKey];
        [archiver finishEncoding];
        [data writeToFile:loginConfigurationFilePath() atomically:YES];
    }
    else{
        [LoginConfiguration deleteLoginConfiguration];
    }
}
#pragma mark - 删除LoginConfiguration
+(void)deleteLoginConfiguration{
    loginConfiguration=[[LoginConfiguration alloc]init];
    [[NSFileManager defaultManager] removeItemAtPath:loginConfigurationFilePath() error:nil];
}

#pragma mark - 保存用户的access_token,refresh_token,expires_in
+(void)saveLoadConfiguration:(NSString *)loadConfiguration saveLoginConfiguration:(BOOL)shouldSaveLoginConfiguration{
    loginConfiguration.shouldSaveLoginConfiguration=shouldSaveLoginConfiguration;
    NSArray *tuples=[loadConfiguration componentsSeparatedByString:@"&"];
    for(NSString *tuple in tuples){
        NSArray *pairs=[tuple componentsSeparatedByString:@"="];
        if([pairs[0] isEqualToString:@"access_token"]){
            loginConfiguration.access_token=pairs[1];
        }
        else if([pairs[0] isEqualToString:@"expires_in"]){
            loginConfiguration.expires_in=pairs[1];
        }
        else if([pairs[0] isEqualToString:@"refresh_token"]){
            loginConfiguration.refresh_token=pairs[1];
        }
    }
    
}
@end
