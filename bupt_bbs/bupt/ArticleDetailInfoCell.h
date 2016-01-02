//
//  ArticleDetailInfoCell.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit.h>
#import "ArticleInfo.h"
#import "ShowUserInfoViewControllerDelegate.h"

extern CGFloat const kMargin;
extern CGFloat const kMaxRatio;
extern CGFloat const kFaceImageViewHeight;

@interface ArticleDetailInfoCell : UITableViewCell<ShowUserInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property (weak, nonatomic) IBOutlet YYLabel *contentLabel;
@property (weak, nonatomic) ArticleInfo *articleInfo;
@property (weak, nonatomic) IBOutlet UIView *labelContainer;
-(void)refreshCustomLayout;
@end
