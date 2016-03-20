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
#import "UserHttpResponseDelegate.h"

@interface LaunchViewController ()<UserHttpResponseDelegate>
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

+(instancetype)getInstanceWithUserId:(NSString*)userid
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @synchronized(self) {
            self.timeUp=YES;
        }
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
-(void)handleUserInfoSuccessWithResponse:(id)response{
    LoginManager *manager=[LoginManager sharedManager];
    manager.currentLoginUserInfo=[UserInfo getUserInfo:response];
    @synchronized(self) {
         self.getUserInfo=YES;
    }
   
    if(self.getUserInfo&&self.timeUp)
        [self showRootView];
}
-(void)handleUserInfoErrorWithResponse:(id)response
                             withError:(NSError *)error{
    self.indicator.hidden=YES ;
    [[LoginManager sharedManager] deleteLoginConfiguration];
    
    [SVProgressHUD show];
    NSString *errorString=[CustomUtilities getNetworkErrorInfoWithResponse:response withError:error];
    [SVProgressHUD showErrorWithStatus:errorString];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
}
@end
