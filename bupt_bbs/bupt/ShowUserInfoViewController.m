//
//  ShowUserInfoViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/15.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ShowUserInfoViewController.h"
#import <UIImageView+WebCache.h>
#import "CustomUtilities.h"
#import "UserInfo.h"
@interface ShowUserInfoViewController ()
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;

@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *astroLabel;
@property (weak, nonatomic) IBOutlet UILabel *qqLabel;
@property (weak, nonatomic) IBOutlet UILabel *msnLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePageLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLoginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLoginIpLabel;
@property (weak, nonatomic) IBOutlet UILabel *isOnlineLabel;

@end

@implementation ShowUserInfoViewController

+(instancetype)getInstance:(id<ShowUserInfoViewControllerDelegate>)delegate{
    ShowUserInfoViewController *controller=[[ShowUserInfoViewController alloc]initWithNibName:@"ShowUserInfo" bundle:nil];
    controller.delegate=delegate;
    return controller;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
    self.screenWidth=[UIScreen mainScreen].bounds.size.width;
    self.screenHeight=[UIScreen mainScreen].bounds.size.height;
    
    self.faceImageView.layer.cornerRadius=self.faceImageView.frame.size.width/2;
    self.faceImageView.clipsToBounds=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark- 显示用户信息
-(void)showUserInfoView{
    self.view.center=CGPointMake(self.screenWidth/2, -self.screenHeight/2);
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.view];
    [self fillUserInfo];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center=CGPointMake(self.screenWidth/2,self.screenHeight/2);
    } completion:nil];
    
}
#pragma mark - 触发隐藏用户信息的事件
- (IBAction)hideUserInfoViewPressed:(id)sender {
    [self.delegate userInfoViewControllerDidDismiss:self];
}
#pragma mark - 完成隐藏用户信息
-(void)hideUserInfoView{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center=CGPointMake(self.screenWidth/2, 3*self.screenHeight/2);
    }];
}
#pragma mark- 填充用户信息
-(void)fillUserInfo{
    if(self.userInfo!=nil){
        [self.faceImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.face_url] placeholderImage:[UIImage imageNamed:@"face_default"]];
        self.userIdLabel.text=self.userInfo.userId;
        self.userNameLabel.text=self.userInfo.user_name;
        self.genderLabel.text=[CustomUtilities getGenderString:self.userInfo.gender];
        self.astroLabel.text=self.userInfo.astro;
        self.qqLabel.text=self.userInfo.qq;
        self.msnLabel.text=self.userInfo.msn;
        self.homePageLabel.text=self.userInfo.home_page;
        self.levelLabel.text=self.userInfo.level;
        self.postCountLabel.text=[NSString stringWithFormat:@"%d篇",self.userInfo.post_count];
        self.scoreLabel.text=[NSString stringWithFormat:@"%d",self.userInfo.score];
        self.lifeLabel.text=[NSString stringWithFormat:@"%d",self.userInfo.life];
        self.lastLoginTimeLabel.text=[CustomUtilities getLastLoginTimeString:self.userInfo.last_login_time];
        self.lastLoginIpLabel.text=self.userInfo.last_login_ip;
        self.isOnlineLabel.text=[CustomUtilities getUserLoginStateString:self.userInfo.is_online];
    }
}

@end
