//
//  AttributedStringUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/9.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedStringDelegate.h"
#import "AttachmentInfo.h"
@interface AttributedStringUtilities : NSObject

+(void)getAttributedStringsWithArray:(NSArray *)array
                         StringColor:(UIColor *)color
                          StringSize:(CGFloat)fontSize
                           BoundSize:(CGSize)boundSize
                            Delegate:(id<AttributedStringDelegate>)delegate;

+(NSMutableAttributedString*)getAttributedStringWithString:(NSString*)                     string
                                               StringColor:(UIColor*)color
                                                StringSize:(CGFloat)size
                                               Attachments:(AttachmentInfo*)attachmentInfo;
@end
