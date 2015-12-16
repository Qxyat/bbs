//
//  GetArticleInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpResponseDelegate <NSObject>

@required
-(void)handleHttpResponse:(id)response;

@optional
-(void)handleSubSectionResponse:(id)response;
-(void)handleUserInfoResponse:(id)response;
@end
