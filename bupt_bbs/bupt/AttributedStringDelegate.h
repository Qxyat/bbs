//
//  AttributedStringDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/9.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AttributedStringDelegate <NSObject>

@required
-(void)handleAttribuedStringResponse:(NSArray*)array;

@end
