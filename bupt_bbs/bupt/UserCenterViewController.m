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
#import <UIButton+WebCache.h>
#import "ShowUserInfoViewController.h"

@interface UserCenterViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *faceButton
;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (strong,nonatomic)ShowUserInfoViewController *showUserInfoViewController;
@end

@implementation UserCenterViewController

+(UserCenterViewController*)getInstance{
    return [[UserCenterViewController alloc]initWithNibName:@"UserCenter" bundle:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
    self.view.frame=[UIScreen mainScreen].bounds;
    //self.containerView.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
    self.containerView.backgroundColor=[UIColor greenColor];
    self.faceButton.layer.cornerRadius=self.faceButton.frame.size.width/2.0;
    self.faceButton.layer.masksToBounds=YES;
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
- (IBAction)faceButtonPressed:(id)sender {
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
    [self.faceButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].currentLoginUserInfo.face_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"face_default"]];
    self.userIdLabel.text=[LoginManager sharedManager].currentLoginUserInfo.userId;
}

@end
