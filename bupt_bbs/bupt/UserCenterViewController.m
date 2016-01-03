//
//  HomeViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UserCenterViewController.h"
#import "UserUtilities.h"
#import "UserInfo.h"
#import "LoginManager.h"
#import "SecondLoginViewController.h"
#import <UIImageView+WebCache.h>
#import "ShowUserInfoViewController.h"
#import <SDWebImageDownloader.h>
#import "ScreenAdaptionUtilities.h"
@interface UserCenterViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (strong,nonatomic)ShowUserInfoViewController *showUserInfoViewController;
@property (weak, nonatomic) IBOutlet UIView *DummyView1;
@property (weak, nonatomic) IBOutlet UIView *DummyView2;
@property (weak, nonatomic) IBOutlet UIView *DummyView3;
@end

@implementation UserCenterViewController

+(instancetype)getInstance{
    return [[UserCenterViewController alloc]initWithNibName:@"UserCenter" bundle:nil];
}
-(void)loadView{
    [super loadView];
    self.view.frame=kCustomScreenBounds;
    [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.faceImageView.layer.cornerRadius=self.faceImageView.frame.size.height/2.0f;
    self.faceImageView.layer.masksToBounds=YES;
    
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(faceImageViewPressed)];
    [self.faceImageView addGestureRecognizer:recognizer];
    [self refresh];
}

#pragma mark - 退出按钮
- (IBAction)logOutButtonPressed:(id)sender {
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
    [self.faceImageView sd_setImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].currentLoginUserInfo.face_url] placeholderImage:[UIImage imageNamed:@"face_default"]];
    self.userIdLabel.text=[LoginManager sharedManager].currentLoginUserInfo.userId;
}

@end
