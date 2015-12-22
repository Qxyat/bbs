//
//  ArticleDetailInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ArticleDetailInfoCell.h"
#import "ShowUserInfoViewController.h"
@interface ArticleDetailInfoCell()

@property (strong,nonatomic)ShowUserInfoViewController*showUserInfoViewController;


@end

@implementation ArticleDetailInfoCell

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    UITapGestureRecognizer *tapGestureRecognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    self.faceImageView.userInteractionEnabled=YES;
    self.nameLabel.userInteractionEnabled=YES;
    [self.faceImageView addGestureRecognizer:tapGestureRecognizer1];
    [self.nameLabel addGestureRecognizer:tapGestureRecognizer2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


#pragma mark - 展示用户信息
-(void)showUserInfo{
    self.showUserInfoViewController=[ShowUserInfoViewController getInstance:self];
    self.showUserInfoViewController.userInfo=self.articleInfo.user;
    [self.showUserInfoViewController showUserInfoView];
}
#pragma mark - 实现ShowUserInfoViewControllerDelegate协议
-(void)userInfoViewControllerDidDismiss:(ShowUserInfoViewController *)userInfoViewController{
    if(self.showUserInfoViewController==userInfoViewController){
        [self.showUserInfoViewController hideUserInfoView];
        self.showUserInfoViewController=nil;
    }
}
@end
