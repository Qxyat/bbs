//
//  FirstLoginViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "FirstLoginViewController.h"
#import "LoginUtilities.h"
#import "BBSConstants.h"
#import <SVProgressHUD.h>
#import "RootViewController.h"
#import "UserUtilities.h"
#import "LoginManager.h"
#import "LaunchViewController.h"
@interface FirstLoginViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;

@property (strong,nonatomic) UIView *loadingView;

@property (nonatomic)BOOL showCancleButton;

@end

@implementation FirstLoginViewController

+(FirstLoginViewController*)getInstance:(BOOL)showCancleButton{
    FirstLoginViewController *controller=[[FirstLoginViewController alloc]initWithNibName:@"FirstLoginView" bundle:nil];
    controller.showCancleButton=showCancleButton;
    return controller;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.loginButton.backgroundColor=[UIColor colorWithRed:kCustomGreenColor.red/255.f green:kCustomGreenColor.green/255.f blue:kCustomGreenColor.blue/255.f alpha:1];
    self.loginButton.layer.cornerRadius=5;
    self.usernameTextField.delegate=self;
    self.passwordTextField.delegate=self;
    self.scrollView.contentSize=CGSizeMake(0, 458);
    self.scrollView.scrollEnabled=NO;
    self.scrollView.bounces=YES;
    
    UITapGestureRecognizer *gesture1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *gesture2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gesture1];
    [self.scrollView addGestureRecognizer:gesture2];
    self.passwordTextField.returnKeyType=UIReturnKeyGo;
    self.passwordTextField.enablesReturnKeyAutomatically=YES;
    [self changeLoginButtonState];
    
    [self.cancleButton setTitleColor:[UIColor colorWithRed:kCustomGreenColor.red/255.f green:kCustomGreenColor.green/255.f blue:kCustomGreenColor.blue/255.f alpha:1] forState:UIControlStateNormal];
    if(!self.showCancleButton){
        self.cancleButton.hidden=YES;
    }
}

#pragma mark - 实现UITextFieldDelegate协议
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self scrollviewScrollWithWidth:0 Height:70];
    self.scrollView.scrollEnabled=YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self scrollviewScrollWithWidth:0 Height:0];
    self.scrollView.scrollEnabled=NO;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.usernameTextField){
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField==self.passwordTextField){
        [self doLogin];
        [self scrollviewScrollWithWidth:0 Height:0];
        [textField resignFirstResponder];
    }
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *before=textField.text;
    NSString *after=[before stringByReplacingCharactersInRange:range withString:string];
    if(((textField==self.usernameTextField&&self.passwordTextField.text.length>0)||(textField==self.passwordTextField&&self.usernameTextField.text.length>0))&&after.length>0){
        self.loginButton.enabled=YES;
        self.loginButton.alpha=1;
    }
    else{
        self.loginButton.alpha=0.6;
        self.loginButton.enabled=NO;
    }
    return YES;
}

#pragma mark - 修改loginbutton状态
-(void)changeLoginButtonState{
    if(self.usernameTextField.text.length>0&&self.passwordTextField.text.length>0){
        self.loginButton.enabled=YES;
        self.loginButton.alpha=1;
        return;
    }
    self.loginButton.alpha=0.6;
    self.loginButton.enabled=NO;
}

#pragma mark - 点击登录按钮
- (IBAction)loginButtonPressed:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self doLogin];
}

#pragma mark - 发送登录信息
-(void)doLogin{
    [self showLoadingview];
    
    [LoginUtilities loginWithUserName:self.usernameTextField.text password:self.passwordTextField.text delegete:self];
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
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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
    [[LoginManager sharedManager]  saveLoginConfiguration:response shouldPersistentStore:YES];
    LaunchViewController *controller=[LaunchViewController getInstanceWithUserId:self.usernameTextField.text FaceUrl:nil WhetherUserFirstLoad:YES];
    [UIApplication sharedApplication].keyWindow.rootViewController=controller;
}
-(void)handleLoginErrorResponse:(id)response{
    [SVProgressHUD showErrorWithStatus:@"账号密码错误"];
    [self hideLoadingview:NO];
}
-(void)handleLoginRealErrorResponse:(id)response{
    NSError *error=(NSError *)response;
    if([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        [SVProgressHUD showErrorWithStatus:@"网络连接已断开"];
    else if([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"The request timed out."]){
        [SVProgressHUD showErrorWithStatus:@"网络连接超时"];
    }
    [self hideLoadingview:NO];
}
#pragma mark - 点击取消按钮
- (IBAction)cancleButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end