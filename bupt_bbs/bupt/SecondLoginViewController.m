//
//  LogInViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SecondLoginViewController.h"
#import "LoginUtilities.h"
#import "RootViewController.h"
#import "FirstLoginViewController.h"
#import "UserUtilities.h"
#import "LoginManager.h"
#import "BBSConstants.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import "LaunchViewController.h"
#import "CustomUtilities.h"
#import "UserHttpResponseDelegate.h"
#import "LoginHttpResponseDelegate.h"
#import "UserInfo.h"

@interface SecondLoginViewController ()<UITextFieldDelegate,LoginHttpResponseDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong,nonatomic) UIView *loadingView;
@end

@implementation SecondLoginViewController
+(instancetype)getInstance{
    SecondLoginViewController *controller=[[SecondLoginViewController alloc]initWithNibName:@"SecondLoginView" bundle:nil];
    return controller;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.loginButton.layer.cornerRadius=5;
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:kCustomGreenColor.red/255.f green:kCustomGreenColor.green/255.f blue :kCustomGreenColor.blue/255.f alpha:1]];
    self.passwordTextField.delegate=self;
    self.scrollView.contentSize=CGSizeMake(0, 400);
    self.scrollView.scrollEnabled=NO;
    self.scrollView.bounces=YES;
    
    UITapGestureRecognizer *gesture1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *gesture2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gesture1];
    [self.scrollView addGestureRecognizer:gesture2];
    self.passwordTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.passwordTextField.returnKeyType=UIReturnKeyGo;
    self.passwordTextField.enablesReturnKeyAutomatically=YES;
    [self disableLoginButton];
    
    LoginManager *manager=[LoginManager sharedManager];
    UserInfo *lastUserInfo=manager.loginUserHistory[0];
    self.userIDLabel.text=lastUserInfo.userId;
    [self.faceImageView sd_setImageWithURL:[NSURL URLWithString:lastUserInfo.face_url] placeholderImage:[UIImage imageNamed:@"face_default"]];
}

#pragma mark - 实现UITextFieldDelegate协议
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self enableScrollView];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self disableScrollView];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.passwordTextField){
        [self doLogin];
        [textField resignFirstResponder];
    }
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *before=textField.text;
    NSString *after=[before stringByReplacingCharactersInRange:range withString:string];
    if(textField==self.passwordTextField&&after.length>0){
        [self enableLoginButton];
    }
    else{
        [self disableLoginButton];
    }
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [self disableLoginButton];
    return YES;
}
#pragma mark - 点击登录按钮
- (IBAction)loginButtonPressed:(id)sender {
    if([self.passwordTextField isFirstResponder])
        [self.passwordTextField resignFirstResponder];
    [self doLogin];
}
#pragma mark - 打开或者关闭LoginButton
-(void)enableLoginButton{
    self.loginButton.enabled=YES;
    self.loginButton.alpha=1;
}
-(void)disableLoginButton{
    self.loginButton.enabled=NO;
    self.loginButton.alpha=0.6;
}
#pragma mark - 点击更多按钮
- (IBAction)moreButtonPressed:(id)sender {
    UIAlertController *controller=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"切换用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        FirstLoginViewController *firstLoginViewController=[FirstLoginViewController getInstance:YES];
        [self.navigationController pushViewController:firstLoginViewController animated:YES];
    }];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [controller addAction:action1];
    [controller addAction:action2];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 发送登录信息
-(void)doLogin{
    [self showLoadingview];
    
    [LoginUtilities loginWithUserName:self.userIDLabel.text password:self.passwordTextField.text delegete:self];
}

#pragma mark - 显示和关闭加载页面
-(void)showLoadingview{
    self.loadingView=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.loadingView.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:0.0];
    [self.view addSubview:self.loadingView];
    [SVProgressHUD showWithStatus:@"请稍候"];
}
-(void)hideLoadingview:(BOOL)success{
    [self.loadingView removeFromSuperview];
    self.loadingView=nil;
    if(success)
        [SVProgressHUD dismiss];
}

#pragma mark - 隐藏键盘
-(void)hideKeyboard{
    if([self.passwordTextField isFirstResponder])
       [self.passwordTextField resignFirstResponder];
}
#pragma mark- 打开或者关闭scrollview
-(void)enableScrollView{
    [self scrollviewScrollWithWidth:0 Height:50];
    self.scrollView.scrollEnabled=YES;
}
-(void)disableScrollView{
    [self scrollviewScrollWithWidth:0 Height:0];
    self.scrollView.scrollEnabled=NO;
}
#pragma mark - 滑动scrollview
-(void)scrollviewScrollWithWidth:(CGFloat)width
                          Height:(CGFloat)height{
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset=CGPointMake(width, height);
    }];
}
#pragma mark - 实现LoginHttpResponseDelegate协议
-(void)handleLoginSuccessResponse:(id)response{
    [self hideLoadingview:YES];
    [[LoginManager sharedManager] saveLoginConfiguration:response shouldPersistentStore:YES];
    LoginManager *manager=[LoginManager sharedManager];
    UserInfo *lastUserInfo=manager.loginUserHistory[0];
    LaunchViewController *controller=[LaunchViewController getInstanceWithUserId:lastUserInfo.userId FaceUrl:lastUserInfo.face_url WhetherUserFirstLoad:NO];
    [UIApplication sharedApplication].keyWindow.rootViewController=controller;
}
-(void)handleLoginErrorResponse:(id)response{
    [SVProgressHUD showErrorWithStatus:@"账号密码错误"];
    [self hideLoadingview:NO];
}
-(void)handleLoginRealErrorResponse:(NSError *)error{
    NSString *errorString=[CustomUtilities getNetworkErrorInfoWithResponse:nil withError:error];
    [SVProgressHUD showErrorWithStatus:errorString];
    [self hideLoadingview:NO];
}

@end
