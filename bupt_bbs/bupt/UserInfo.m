//
//  UserInfo.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UserInfo.h"
static NSString* const kUserId=@"id";
static NSString* const kUserName=@"user_name";
static NSString* const kFaceUrl=@"face_url";
static NSString* const kFaceWidth=@"face_width";
static NSString* const kFaceHeight=@"face_height";
static NSString* const kGender=@"gender";
static NSString* const kAstro=@"astro";
static NSString* const kLife=@"life";
static NSString* const kQQ=@"qq";
static NSString* const kMSN=@"msn";
static NSString* const kHomePage=@"home_page";
static NSString* const kLevel=@"level";
static NSString* const kIsOnline=@"is_online";
static NSString* const kPostCount=@"post_count";
static NSString* const kLastLoginTime=@"last_login_time";
static NSString* const kLastLoginIp=@"last_login_ip";
static NSString* const kIsHide=@"is_hide";
static NSString* const kIsRegister=@"is_register";
static NSString* const kScore=@"score";
static NSString* const kFirstLoginTime=@"first_login_time";
static NSString* const kLoginCount=@"login_count";
static NSString* const kIsAdmin=@"is_admin";
static NSString* const kStayCount=@"stay_count";

@implementation UserInfo

#pragma mark - 实现NSCoding协议
-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super init]){
        self.userId=[aDecoder decodeObjectForKey:kUserId];
        self.face_url=[aDecoder decodeObjectForKey:kFaceUrl];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.userId forKey:kUserId];
    [aCoder encodeObject:self.face_url forKey:kFaceUrl];
}
+(UserInfo*)getUserInfo:(id)item{
    UserInfo *user=nil;
    if(item!=[NSNull null]){
        NSDictionary *dic=(NSDictionary*)item;
        user=[[UserInfo alloc]init];
        user.userId=[dic objectForKey:kUserId];
        user.user_name=[dic objectForKey:kUserName];
        user.face_url=[dic objectForKey:kFaceUrl];
        user.face_width=[[dic objectForKey:kFaceWidth]intValue];
        user.face_height=[[dic objectForKey:kFaceHeight]intValue];
        user.gender=[dic objectForKey:kGender];
        user.astro=[dic objectForKey:kAstro];
        user.life=[[dic objectForKey:kLife] intValue];
        user.qq=[dic objectForKey:kQQ];
        user.msn=[dic objectForKey:kMSN];
        user.home_page=[dic objectForKey:kHomePage];
        user.level=[dic objectForKey:kLevel];
        user.is_online=[[dic objectForKey:kIsOnline]boolValue];
        user.post_count=[[dic objectForKey:kPostCount]intValue];
        user.last_login_time=[[dic objectForKey:kLastLoginTime]intValue];
        user.last_login_ip=[dic objectForKey:kLastLoginIp];
        user.is_hide=[[dic objectForKey:kIsHide]boolValue];
        user.is_register=[[dic objectForKey:kIsRegister]boolValue];
        user.first_login_time=[[dic objectForKey:kFirstLoginTime]intValue];
        user.login_count=[[dic objectForKey:kLoginCount]intValue];
        user.is_admin=[[dic objectForKey:kIsAdmin] boolValue];
        user.stay_count=[[dic objectForKey:kStayCount] intValue];
    }
    
    return user;
}
@end
