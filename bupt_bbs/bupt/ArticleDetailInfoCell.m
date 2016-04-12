//
//  ArticleDetailInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIImage+GIF.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <SDWebImageDownloader.h>
#import "ArticleDetailInfoCell.h"
#import "UserInfoViewController.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"
#import "DownloadResourcesUtilities.h"
#import "PictureInfo.h"
#import "YYImage+Emoji.h"
#import "ReplyViewController.h"
#import "UserInfo.h"

CGFloat const kMargin=4;
CGFloat const kMaxRatio=1.6;
CGFloat const kFaceImageViewHeight=30;

@interface ArticleDetailInfoCell()

@end

@implementation ArticleDetailInfoCell

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    UITapGestureRecognizer *tapGestureRecognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    self.faceImageView.userInteractionEnabled=YES;
    self.nameLabel.userInteractionEnabled=YES;
    [self.faceImageView addGestureRecognizer:tapGestureRecognizer1];
    [self.nameLabel addGestureRecognizer:tapGestureRecognizer2];
    UITapGestureRecognizer *tapGestureRecognizer3=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyArticle)];
    [self.replyImageView addGestureRecognizer:tapGestureRecognizer3];
    [self setSeparatorInset:UIEdgeInsetsMake(0, kMargin, 0, kMargin)];
}


#pragma mark -
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
    self.labelContainer.frame=CGRectMake(2*kMargin+imageviewWidth, kMargin, kCustomScreenWidth-3*kMargin-imageviewWidth, kFaceImageViewHeight);
    self.nameLabel.frame=CGRectMake(0,0,self.labelContainer.frame.size.width*0.8, self.labelContainer.frame.size.height*0.5);
    self.floorLabel.frame=CGRectMake(self.labelContainer.frame.size.width*0.85, 0, 0.1*self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.timeLabel.frame=CGRectMake(0,self.labelContainer.frame.size.height*0.5,self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.contentLabel.frame=CGRectMake(kMargin,2*kMargin+kFaceImageViewHeight,  kCustomScreenWidth-2*kMargin, self.contentLabel.frame.size.height);
    self.replyImageView.frame=CGRectMake(kCustomScreenWidth-2*kMargin-kFaceImageViewHeight, 3*kMargin+kFaceImageViewHeight+self.contentLabel.frame.size.height, kFaceImageViewHeight, kFaceImageViewHeight);
    self.contentView.frame=CGRectMake(0,0,kCustomScreenWidth,4*kMargin+2*kFaceImageViewHeight+self.contentLabel.frame.size.height);
}

#pragma mark - 填写cell内容
-(void)setArticleInfo:(ArticleInfo *)articleInfo{
    _articleInfo=articleInfo;
    
    YYImage *cachedFaceImage=[DownloadResourcesUtilities getImageFromDisk:articleInfo.user.face_url];
    
    if(cachedFaceImage){
        self.faceImageView.image=cachedFaceImage;
        if(cachedFaceImage.animatedImageType==YYImageTypeGIF)
            [self.faceImageView startAnimating];
        [self refreshCustomLayout];
    }
    else{
        _faceImageView.image=[UIImage imageNamed:@"face_default"];
        __weak typeof (self) _weakself=self;
        [DownloadResourcesUtilities downloadImage:articleInfo.user.face_url FromBBS:YES Completed:^(YYImage *image,BOOL isFailed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _weakself.faceImageView.image=image;
                if(image.animatedImageType==YYImageTypeGIF)
                    [_weakself.faceImageView startAnimating];
                [_weakself refreshCustomLayout];
            });
        }];
    }
    
    self.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    self.timeLabel.text=[CustomUtilities getPostTimeString:articleInfo.post_time];
    self.nameLabel.text=articleInfo.user.userId;
    
    self.contentLabel.attributedText=articleInfo.contentAttributedString;
    self.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=self.contentLabel.frame;
    contentLabelNewFrame.size=[articleInfo.contentSize CGSizeValue];
    self.contentLabel.frame=contentLabelNewFrame;
    
    [articleInfo startDownloadPictures];
    
    [self refreshCustomLayout];
}


#pragma mark - 展示用户信息
-(void)showUserInfo{
    [_delegate showUserInfoViewController:self.articleInfo.user];
}

#pragma mark - 打开回复文章
-(void)replyArticle{
    [_delegate showReplyViewControllerWithBoardName:self.articleInfo.board_name isNewTheme:NO ArtilceName:self.articleInfo.title ArticleID:self.articleInfo.articleId ArticleInfo:self.articleInfo];
}

@end
