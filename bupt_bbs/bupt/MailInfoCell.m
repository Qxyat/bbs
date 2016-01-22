//
//  MailInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailInfoCell.h"
#import "MailInfo.h"
#import "DownloadResourcesUtilities.h"
#import "UserInfo.h"
#import "CustomUtilities.h"

#import <YYKit.h>

@interface MailInfoCell ()

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *useridLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *posttimeLabel;


@end

@implementation MailInfoCell

-(void)awakeFromNib{
    _faceImageView.contentMode=UIViewContentModeScaleAspectFit;
}

-(void)setMailInfo:(MailInfo *)mailInfo{
    _mailInfo=mailInfo;
    
    typeof(self) _wkself=self;
    
    if(mailInfo.isUserExist){
        UserInfo *user=(UserInfo*)mailInfo.user;
        YYImage *cachedImage=[DownloadResourcesUtilities downloadImage:user.face_url FromBBS:NO Completed:^(YYImage *image) {
            _wkself.faceImageView.image=image;
            if(image.animatedImageType==YYImageTypeGIF){
                [_wkself.faceImageView startAnimating];
            }
        }];
        if(cachedImage){
            _faceImageView.image=cachedImage;
            if(cachedImage.animatedImageType==YYImageTypeGIF){
                [_faceImageView startAnimating];
            }
        }
        _useridLabel.text=user.userId;
    }
    else{
        _faceImageView.image=[YYImage imageNamed:@"face_default"];
        _useridLabel.text=mailInfo.user;
    }
    
    _titleLabel.text=mailInfo.title;
    _posttimeLabel.text=[CustomUtilities getPostTimeString:mailInfo.post_time];
}

@end
