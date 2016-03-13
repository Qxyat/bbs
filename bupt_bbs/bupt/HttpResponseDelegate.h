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
-(void)handleHttpSuccessWithResponse:(id)response;
-(void)handleHttpErrorWithResponse:(id)response
                         withError:(NSError *)error;



@end
