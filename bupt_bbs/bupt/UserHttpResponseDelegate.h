//
//  UserHttpResponseDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserHttpResponseDelegate <NSObject>

-(void)handleUserInfoSuccessWithResponse:(id)response;
-(void)handleUserInfoErrorWithResponse:(id)response
                             withError:(NSError *)error;

@end
