//
//  SectionHttpResponseDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/3/13.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SectionHttpResponseDelegate <NSObject>

@optional
-(void)handleSectionSucessWithResponse:(id)response
                      isSubSectionRequest:(BOOL)isSubSectionRequest
                                 subIndex:(NSUInteger)index;
-(void)handleSectionErrorWithResponse:(id)response
                            withError:(NSError *)error
                     isSubSectionRequest:(BOOL)isSubSectionRequest
                                subIndex:(NSUInteger)index;


-(void)handleHttpSuccessWithResponse:(id)response;
-(void)handleHttpErrorWithResponse:(id)response
                         withError:(NSError *)error;

@end
