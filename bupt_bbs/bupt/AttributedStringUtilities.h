//
//  CaluateAttributedStringSizeUtilities.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/14.
//  Copyright © 2015年 qiu. All rights reserved.
//
#import <UIKit/UIKit.h>
@class ArticleInfo;

@protocol AttributedStringUtilitiesDelegate <NSObject>

-(void)updateAttributedString;
-(void)pictureTapped:(UIGestureRecognizer*)recognizer;

@end

CGSize sizeThatFitsAttributedString(NSAttributedString *attributedString,
                                    CGSize size,NSUInteger numberOfLines);

@interface AttributedStringUtilities : NSObject

@property (nonatomic,readwrite,weak) ArticleInfo<AttributedStringUtilitiesDelegate>* delegate;

-(NSMutableAttributedString*)getAttributedStringWithArticle:(ArticleInfo*)article
                                                  fontColor:(UIColor*)color
                                                   fontSize:(CGFloat)size;
-(void)addDownloadOperation;
-(void)addDownloadFaidedOperation;
@end