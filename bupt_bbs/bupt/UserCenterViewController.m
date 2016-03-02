//
//  HomeViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UserCenterViewController.h"
#import "LoginManager.h"
#import "SecondLoginViewController.h"
#import "ShowUserInfoViewController.h"
#import "DownloadResourcesUtilities.h"
#import "MailboxViewController.h"
#import "RootViewController.h"
#import "FavoriteViewController.h"

#import <Masonry.h>
#import <YYKit.h>

@interface UserCenterViewController ()
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) YYAnimatedImageView *faceImageView;
@property (strong, nonatomic) UIImageView *mailboxImageView;
@property (strong, nonatomic) UIButton *mailboxButton;

@property (strong, nonatomic) UIImageView *favoriteImageView;
@property (strong, nonatomic) UIButton *favoriteButton;

@property (strong, nonatomic) UILabel *userIdLabel;
@property (strong, nonatomic) UIButton *quitButton;
@property (strong,nonatomic)ShowUserInfoViewController *showUserInfoViewController;

@end

@implementation UserCenterViewController

+(instancetype)getInstance{
    return [[UserCenterViewController alloc]init];
}
-(void)loadView{
    [super loadView];
    
    _containerView=[[UIView alloc] init];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.centerY.equalTo(self.view.mas_centerY);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.77);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.77);
    }];
    
    _faceImageView=[[YYAnimatedImageView alloc]init];
    _faceImageView.contentMode=UIViewContentModeScaleToFill;
    _faceImageView.userInteractionEnabled=YES;
    [_containerView addSubview:_faceImageView];
    [_faceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_containerView.mas_centerX);
        make.height.equalTo(_containerView.mas_height).multipliedBy(0.2);
        make.width.equalTo(_containerView.mas_height).multipliedBy(0.2);
        make.top.equalTo(_containerView.mas_bottom).multipliedBy(0.1);
    }];
    
    _userIdLabel=[[UILabel alloc]init];
    _userIdLabel.contentMode=UIViewContentModeCenter;
    _userIdLabel.textAlignment=NSTextAlignmentCenter;
    _userIdLabel.font=[UIFont systemFontOfSize:16];
    _userIdLabel.minimumScaleFactor=0.6;
    [_containerView addSubview:_userIdLabel];
    [_userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_containerView.mas_centerX);
        make.top.equalTo(_containerView.mas_bottom).multipliedBy(0.35);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.5);
        make.height.equalTo(_containerView.mas_height).multipliedBy(0.05);
    }];
    
    _mailboxImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Mailbox"]];
    _mailboxImageView.contentMode=UIViewContentModeScaleToFill;
    [_containerView addSubview:_mailboxImageView];
    [_mailboxImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.3);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.1);
        make.height.equalTo(_containerView.mas_height).multipliedBy(0.05);
        make.top.equalTo(_containerView.mas_bottom).multipliedBy(0.5);
    }];
    
    _mailboxButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _mailboxButton.titleLabel.font=[UIFont systemFontOfSize:16];
    _mailboxButton.titleLabel.minimumScaleFactor=0.6;
    _mailboxButton.titleLabel.textAlignment=NSTextAlignmentLeft;
    [_mailboxButton setTitle:@"我的信箱" forState:UIControlStateNormal];
    [_mailboxButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_mailboxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_mailboxButton addTarget:self action:@selector(mailboxButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_mailboxButton];
    [_mailboxButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.4);
        make.height.equalTo(_mailboxImageView.mas_height);
        make.top.equalTo(_mailboxImageView.mas_top);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.4);
    }];
    
    _favoriteImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"favorite"]];
    _favoriteImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_containerView addSubview:_favoriteImageView];
    [_favoriteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.3);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.1);
        make.height.equalTo(_containerView.mas_height).multipliedBy(0.05);
        make.top.equalTo(_containerView.mas_bottom).multipliedBy(0.6);
    }];
    
    _favoriteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteButton.titleLabel.font=[UIFont systemFontOfSize:16];
    _favoriteButton.titleLabel.minimumScaleFactor=0.6;
    _favoriteButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    [_favoriteButton setTitle:@"我的收藏" forState:UIControlStateNormal];
    [_favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_favoriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_favoriteButton addTarget:self action:@selector(favoriteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_favoriteButton];
    [_favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.4);
        make.height.equalTo(_favoriteImageView.mas_height);
        make.top.equalTo(_favoriteImageView.mas_top);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.4);
    }];
    
    _quitButton=[UIButton buttonWithType:UIButtonTypeCustom];;
    _quitButton.titleLabel.font=[UIFont systemFontOfSize:16];
    [_quitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    _quitButton.titleLabel.minimumScaleFactor=0.6;
    _quitButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    [_quitButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [_quitButton addTarget:self action:@selector(quitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_quitButton];
    [_quitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_containerView.mas_centerX);
        make.top.equalTo(_containerView.mas_bottom).multipliedBy(0.8);
        make.height.equalTo(_containerView.mas_height).multipliedBy(0.05);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.5);
    }];
    [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _faceImageView.layer.cornerRadius=_faceImageView.frame.size.height/2.0f;
    _faceImageView.layer.masksToBounds=YES;
    
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(faceImageViewPressed)];
    [_faceImageView addGestureRecognizer:recognizer];

    [self refresh];
}

#pragma mark - 退出按钮
- (void)quitButtonPressed{
    [[LoginManager sharedManager] deleteLoginConfiguration];
    SecondLoginViewController *secondLoginViewController=[SecondLoginViewController getInstance];
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:secondLoginViewController];
    navigationController.navigationBar.hidden=YES;
    [UIApplication sharedApplication].keyWindow.rootViewController=navigationController;
}

#pragma mark - 查看当前登陆用户信息
- (void)faceImageViewPressed{
    self.showUserInfoViewController=[ShowUserInfoViewController getInstance:self];
    self.showUserInfoViewController.userInfo=[LoginManager sharedManager].currentLoginUserInfo;
    [self.showUserInfoViewController showUserInfoView];
}

#pragma mark - 实现ShowUserInfoViewControllerDelegate协议
-(void)userInfoViewControllerDidDismiss:(ShowUserInfoViewController *)userInfoViewController{
    if(self.showUserInfoViewController==userInfoViewController){
        [self.showUserInfoViewController hideUserInfoView];
        self.showUserInfoViewController=nil;
    }
}

#pragma mark - 刷新用户个人中心界面
-(void)refresh{
    typeof(self) wkself=self;
    YYImage *cacheImage=[DownloadResourcesUtilities downloadImage:[LoginManager sharedManager].currentLoginUserInfo.face_url FromBBS:NO Completed:^(YYImage *image) {
        wkself.faceImageView.image=image;
    }];
    if(cacheImage){
        _faceImageView.image=cacheImage;
    }
    _userIdLabel.text=[LoginManager sharedManager].currentLoginUserInfo.userId;
}

#pragma mark - 信箱按钮
-(void)mailboxButtonPressed{
    RootViewController *rootViewController=(RootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    MailboxViewController *mailboxViewController=[MailboxViewController getInstance];
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:mailboxViewController];
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - 收藏按钮
-(void)favoriteButtonPressed{
    RootViewController *rootViewController=(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    FavoriteViewController *favoriteViewController=[FavoriteViewController getInstance];
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:favoriteViewController];
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
}
@end
