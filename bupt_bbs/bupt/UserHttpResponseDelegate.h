//
//  UserHttpResponseDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserHttpResponseDelegate <NSObject>

-(void)handleUserInfoSuccessResponse:(id)response;
-(void)handleUserInfoErrorResponse:(id)response;

@end
