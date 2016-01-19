//
//  ReplyViewImageCell.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/17.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReplyViewImageCellDelegate.h"

@interface ReplyViewImageCell : UICollectionViewCell

@property(strong,nonatomic)UIImage*image;
@property(strong,nonatomic)NSString *name;
@property(nonatomic)       NSInteger pos;
@property(weak,nonatomic)id<ReplyViewImageCellDelegate>delegate;

@end
