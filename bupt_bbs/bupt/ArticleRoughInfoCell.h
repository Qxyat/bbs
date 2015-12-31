//
//  ArticleRoughInfoCell.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/28.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleRoughInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *boardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *boardContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyCountImageView;
@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;
@end
