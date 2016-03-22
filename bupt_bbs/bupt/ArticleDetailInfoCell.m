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
#import "ShowUserInfoViewController.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"
#import "AttributedStringUtilities.h"
#import "AttachmentInfo.h"
#import "AttachmentFile.h"
#import "DownloadResourcesUtilities.h"
#import "PictureInfo.h"
#import "LoginManager.h"
#import "YYImage+Emoji.h"
#import "ReplyViewController.h"
#import "UserInfo.h"

CGFloat const kMargin=4;
CGFloat const kMaxRatio=1.6;
CGFloat const kFaceImageViewHeight=30;

@interface ArticleDetailInfoCell()<ShowUserInfoViewControllerDelegate,MWPhotoBrowserDelegate,ArticleInfoDelegate>

@property (strong,nonatomic)ShowUserInfoViewController*showUserInfoViewController;
@property (strong,nonatomic)MWPhotoBrowser *photoBrowser;
@property (strong,nonatomic)NSMutableArray *photos;

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

#pragma mark -实现MWPhotoBrowserDelegate协议
-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return _photos.count;
}
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if(index<self.articleInfo.pictures.count){
        return _photos[index];
    }
    return nil;
}
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    if(index<self.articleInfo.pictures.count){
        return _photos[index];
    }
    return nil;
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
#pragma mark - 填写cell内容
-(void)setArticleInfo:(ArticleInfo *)articleInfo{
    if(_articleInfo!=nil){
        [_articleInfo removeCellObserver];
        _articleInfo.delegate=nil;
    }
    
    _articleInfo=articleInfo;
    _articleInfo.delegate=self;
    [_articleInfo addCellObserver];
    
    
    
    _photoBrowser=[[MWPhotoBrowser alloc]initWithDelegate:self];
    _photoBrowser.displayActionButton=NO;
   
    _photos=[[NSMutableArray alloc]initWithCapacity:_articleInfo.pictures.count];
    for(int i=0;i<_articleInfo.pictures.count;i++){
        PictureInfo *picture=_articleInfo.pictures[i];
        NSURL *url=nil;
        if(picture.isFromBBS){
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@?oauth_token=%@",picture.original_url,[LoginManager sharedManager].access_token]];
        }
        else{
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@",picture.original_url]];
        }

        [_photos addObject:[MWPhoto photoWithURL:url]];
    }

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
    
    [self refreshCustomLayout];
}


#pragma mark - 实现当值发生变化后，更新
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"contentSize"]){
        dispatch_async(dispatch_get_main_queue(), ^{
                           [_delegate refreshTableView:_articleInfo];
                       });
    }
}
#pragma mark - 点击图片后相应的反馈
-(void)pictureTapped:(UIGestureRecognizer*)recognizer{
    YYAnimatedImageView *imageView=(YYAnimatedImageView*)recognizer.view;
    UITableViewController *controller=(UITableViewController*)self.delegate;
    [_photoBrowser setCurrentPhotoIndex:imageView.tag];
    [controller.navigationController pushViewController:_photoBrowser animated:YES];
}

#pragma mark - 打开回复文章的标题
-(void)replyArticle{
    UITableViewController *controller=(UITableViewController*)self.delegate;
    [controller.navigationController pushViewController:[ReplyViewController getInstanceWithBoardName:self.articleInfo.board_name isNewTheme:NO withArticleName:self.articleInfo.title withArticleId:self.articleInfo.articleId withArticleInfo:self.articleInfo ] animated:YES];
}

@end
