//
//  LoginConfiguration.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/24.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "LoginManager.h"
#import "UserInfo.h"

static NSString *const kLoginConfigurationKey=@"LoginConfiguration";

static NSString *const kAccessTokenKey=@"access_token";
static NSString *const kRefreshTokenKey=@"refresh_token";
static NSString *const kExpireInKey=@"expires_in";
static NSString *const kLoginUserHistory=@"loginuserhistory";


static NSString * loginConfigurationFilePath(){
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"loginconfiguration.archive"];
}
@interface LoginManager()

@property (strong,nonatomic)dispatch_queue_t concurrentQueue;

@end

@implementation LoginManager

#pragma mark - 获得LoginManager的单例
+(instancetype)sharedManager{
    static LoginManager * manager=nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        NSData *data=[[NSData alloc]initWithContentsOfFile:loginConfigurationFilePath()];
        if(data==nil){
            manager=[[LoginManager alloc]init];
        }
        else{
            NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            manager=[unarchiver decodeObjectForKey:kLoginConfigurationKey];
            manager.concurrentQueue=dispatch_queue_create("LoginMangerQueue", DISPATCH_QUEUE_CONCURRENT);
            [unarchiver finishDecoding];
        }
    });
    return manager;
}

-(id)init{
    if(self=[super init]){
        self.access_token=nil;
        self.refresh_token=nil;
        self.expires_in=nil;
        self.loginUserHistory=[[NSMutableArray alloc]initWithCapacity:5];
        self.concurrentQueue=dispatch_queue_create("LoginMangerQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return  self;
}


#pragma mark - 注销登录
-(void)deleteLoginConfiguration{
    self.access_token=nil;
    self.refresh_token=nil;
    self.expires_in=nil;
    _currentLoginUserInfo=nil;
    [self _persistentStore];
}

#pragma mark - 保存用户的access_token,refresh_token,expires_in
-(void)saveLoginConfiguration:(NSString*)loadConfiguration
        shouldPersistentStore:(BOOL)shouldPersistentStore{
    dispatch_barrier_async(_concurrentQueue, ^{
        NSArray *tuples=[loadConfiguration componentsSeparatedByString:@"&"];
        for(NSString *tuple in tuples){
            NSArray *pairs=[tuple componentsSeparatedByString:@"="];
            if([pairs[0] isEqualToString:@"access_token"]){
                _access_token=pairs[1];
            }
            else if([pairs[0] isEqualToString:@"expires_in"]){
                _expires_in=pairs[1];
            }
            else if([pairs[0] isEqualToString:@"refresh_token"]){
                _refresh_token=pairs[1];
            }
        }
        if(shouldPersistentStore){
            [self _persistentStore];
        }
    });
}

#pragma mark - 持久化存储
-(void)_persistentStore {
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:kLoginConfigurationKey];
    [archiver finishEncoding];
    [data writeToFile:loginConfigurationFilePath() atomically:YES];
}

#pragma mark - 重写的保存当前登陆用户信息
-(void)setCurrentLoginUserInfo:(UserInfo *)currentLoginUserInfo{
    dispatch_barrier_async(_concurrentQueue, ^{
        _currentLoginUserInfo=currentLoginUserInfo;
        int i=0;
        for(i=0;i<self.loginUserHistory.count;i++){
            UserInfo *tmp=self.loginUserHistory[i];
            if([tmp.userId isEqualToString:currentLoginUserInfo.userId])
                break;
        }
        if(i<self.loginUserHistory.count)
            [self.loginUserHistory removeObjectAtIndex:i];
        [self.loginUserHistory insertObject:currentLoginUserInfo atIndex:0];
        if(self.loginUserHistory.count>5){
            [self.loginUserHistory removeObjectAtIndex:self.loginUserHistory.count];
        }
        [self _persistentStore];
    });
}

#pragma mark - 实现NSCoding协议
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.access_token forKey:kAccessTokenKey];
    [aCoder encodeObject:self.refresh_token forKey:kRefreshTokenKey];
    [aCoder encodeObject:self.expires_in forKey:kExpireInKey];
    [aCoder encodeObject:self.loginUserHistory forKey:kLoginUserHistory];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super init]){
        self.access_token=[aDecoder decodeObjectForKey:kAccessTokenKey];
        self.refresh_token=[aDecoder decodeObjectForKey:kRefreshTokenKey];
        self.expires_in=[aDecoder decodeObjectForKey:kExpireInKey];
        self.loginUserHistory=[aDecoder decodeObjectForKey:kLoginUserHistory];
    }
    return self;
}
@end
