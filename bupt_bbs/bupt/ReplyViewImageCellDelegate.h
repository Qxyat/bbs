//
//  ReplyImageCellDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/19.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReplyViewImageCellDelegate <NSObject>

-(void)tapImageView:(NSString*)name
       withPosition:(NSInteger)pos;

@end
