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
#import "LoginConfiguration.h"
#import "FirstLoginViewController.h"
#import <UIButton+WebCache.h>
#import "ShowUserInfoViewController.h"

static CGFloat const kProportion=0.77;
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
    self.view.backgroundColor=[UIColor darkGrayColor];
    CGFloat width=[UIScreen mainScreen].bounds.size.width;
    self.containerView.center=CGPointMake(width*kProportion/2, self.containerView.center.y);
    self.containerView.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
    self.faceButton.layer.cornerRadius=self.faceButton.frame.size.width/2.0;
    self.faceButton.layer.masksToBounds=YES;
    [self refresh];
}
- (IBAction)logOutButtonPressed:(id)sender {
    [LoginConfiguration deleteLoginConfiguration];
    [UIApplication sharedApplication].keyWindow.rootViewController=[FirstLoginViewController getInstance];
}
- (IBAction)faceButtonPressed:(id)sender {
    self.showUserInfoViewController=[ShowUserInfoViewController getInstance:self];
    self.showUserInfoViewController.userInfo=[LoginConfiguration getInstance].loginUserInfo;
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
    [self.faceButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[LoginConfiguration getInstance].loginUserInfo.face_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"face_default"]];
    self.userIdLabel.text=[LoginConfiguration getInstance].loginUserInfo.userId;
}

@end
