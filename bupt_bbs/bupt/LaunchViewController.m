//
//  LaunchViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/18.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "LaunchViewController.h"
#include "UserUtilities.h"
#import <UIImageView+WebCache.h>
#import "UserInfo.h"
#import "LoginManager.h"
#import "RootViewController.h"
#import <SVProgressHUD.h>
#import "SecondLoginViewController.h"
#import "CustomUtilities.h"

@interface LaunchViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *userdIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong,nonatomic)NSString * userId;
@property (strong,nonatomic)NSString * faceUrl;
@property (nonatomic)BOOL firstLoad;
@property (nonatomic)__block BOOL timeUp;
@property (nonatomic)BOOL getUserInfo;
@end

@implementation LaunchViewController

+(LaunchViewController*)getInstanceWithUserId:(NSString*)userid
                                      FaceUrl:(NSString*)faceUrl
                         WhetherUserFirstLoad:(BOOL)firstLoad{
    LaunchViewController *controller=[[LaunchViewController alloc]init];
    controller.firstLoad=firstLoad;
    controller.userId=userid;
    controller.faceUrl=faceUrl;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.faceImageView.layer.cornerRadius=self.faceImageView.frame.size.width/2;
    self.faceImageView.clipsToBounds=YES;
    
    self.userdIdLabel.text=self.userId;
    if(self.firstLoad){
        self.faceImageView.image=[UIImage imageNamed:@"logo"];
        self.welcomeLabel.text=@"欢迎新用户的加入";
    }
    else{
        [self.faceImageView sd_setImageWithURL:[NSURL URLWithString:self.faceUrl] placeholderImage:[UIImage imageNamed:@"face_default"]];
        self.welcomeLabel.text=@"欢迎回来";
    }
    self.timeUp=NO;
    self.getUserInfo=NO;
    [UserUtilities getLoginUserInfo:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [NSThread sleepForTimeInterval:3];
        self.timeUp=YES;
        if(self.timeUp&&self.getUserInfo){
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self showRootView];
            });
        }
    });
    [self.indicator startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 显示主界面
-(void)showRootView{
    RootViewController *controller=[RootViewController getInstance];
    [UIApplication sharedApplication].keyWindow.rootViewController=controller;
}
#pragma mark - 实现UserHttpResponseDelegate协议
-(void)handleUserInfoSuccessResponse:(id)response{
    LoginManager *manager=[LoginManager sharedManager];
    manager.currentLoginUserInfo=[UserInfo getUserInfo:response];
    self.getUserInfo=YES;
    if(self.getUserInfo&&self.timeUp)
        [self showRootView];
}
-(void)handleUserInfoErrorResponse:(id)response{
    self.indicator.hidden=YES ;
    [[LoginManager sharedManager] deleteLoginConfiguration];
    
    [SVProgressHUD show];
    NSError *error=(NSError *)response;
    NetworkErrorCode errorCode=[CustomUtilities getNetworkErrorCode:error];
    switch (errorCode) {
        case NetworkConnectFailed:
            [SVProgressHUD showErrorWithStatus:@"网络连接已断开，请重新登录"];
            break;
        case NetworkConnectTimeout:
            [SVProgressHUD showErrorWithStatus:@"网络连接超时，请重新登录"];
            break;
        case NetworkConnectUnknownReason:
            [SVProgressHUD showErrorWithStatus:@"获取用户信息失败，请重新登录"];
            break;
        default:
            break;
    }
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.firstLoad){
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                SecondLoginViewController *secondLoginViewController=[SecondLoginViewController getInstance];
                UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:secondLoginViewController];
                navigationController.navigationBar.hidden=YES;
                [UIApplication sharedApplication].keyWindow.rootViewController=navigationController;
            }
        });
    });
}
@end
