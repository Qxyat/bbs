//
//  BoardArticleInfoCellTableViewCell.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardArticleInfoCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;

@end
