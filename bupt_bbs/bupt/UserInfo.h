//
//  UserInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<NSCoding>

@property(strong,nonatomic) NSString* userId;
@property(strong,nonatomic) NSString* user_name;
@property(strong,nonatomic) NSString* face_url;
@property(nonatomic)        int       face_width;
@property(nonatomic)        int       face_height;
@property(strong,nonatomic) NSString* gender;
@property(strong,nonatomic) NSString* astro;
@property(nonatomic)        int       life;
@property(strong,nonatomic) NSString* qq;
@property(strong,nonatomic) NSString* msn;
@property(strong,nonatomic) NSString* home_page;
@property(strong,nonatomic) NSString* level;
@property(nonatomic)        BOOL      is_online;
@property(nonatomic)        int       post_count;
@property(nonatomic)        int       last_login_time;
@property(strong,nonatomic) NSString* last_login_ip;
@property(nonatomic)        BOOL      is_hide;
@property(nonatomic)        BOOL      is_register;
@property(nonatomic)        int       score;
@property(nonatomic)        int       first_login_time;
@property(nonatomic)        int       login_count;
@property(nonatomic)        BOOL      is_admin;
@property(nonatomic)        int       stay_count;

+(UserInfo*)getUserInfo:(id)item;
@end
