//
//  ArticleDetailInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ArticleDetailInfoCell.h"
#import "ShowUserInfoViewController.h"
#import "ScreenAdaptionUtilities.h"

CGFloat const kMargin=4;
CGFloat const kMaxRatio=1.6;
CGFloat const kFaceImageViewHeight=30;

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
    [self setSeparatorInset:UIEdgeInsetsMake(0, kMargin, 0, kMargin)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self refreshCustomLayout];
}
-(void)refreshCustomLayout{
    CGFloat imageviewHeight=kFaceImageViewHeight;
    CGFloat ratio=1;
    CGFloat imageviewWidth=kFaceImageViewHeight;
    
    if(self.faceImageView.image.size.height>0){
        ratio=self.faceImageView.image.size.width/self.faceImageView.image.size.height;
        if(ratio>kMaxRatio){
            ratio=kMaxRatio;
        }
    }
    imageviewWidth=imageviewHeight*ratio;
    
    self.faceImageView.frame=CGRectMake(kMargin, kMargin, imageviewWidth, imageviewHeight);
    self.replyImageView.frame=CGRectMake(kCustomScreenWidth-kMargin-kFaceImageViewHeight, kMargin, kFaceImageViewHeight, kFaceImageViewHeight);
    self.labelContainer.frame=CGRectMake(2*kMargin+imageviewWidth, kMargin, kCustomScreenWidth-4*kMargin-imageviewWidth-kFaceImageViewHeight, kFaceImageViewHeight);
    self.floorLabel.frame=CGRectMake(0, 0, 0.25*self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.timeLabel.frame=CGRectMake(self.floorLabel.frame.size.width, 0, 0.75*self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.nameLabel.frame=CGRectMake(0,self.labelContainer.frame.size.height*0.5,self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.contentLabel.frame=CGRectMake(kMargin,2*kMargin+kFaceImageViewHeight,  kCustomScreenWidth-2*kMargin, self.contentLabel.frame.size.height);
    self.contentView.frame=CGRectMake(0,0,kCustomScreenWidth,3*kMargin+kFaceImageViewHeight+self.contentLabel.frame.size.height);
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
