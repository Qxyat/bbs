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
@interface FirstLoginViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation FirstLoginViewController

+(FirstLoginViewController*)getInstance{
    FirstLoginViewController *controller=[[FirstLoginViewController alloc]initWithNibName:@"FirstLoginView" bundle:nil];
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
    
    UITapGestureRecognizer *gesture1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    UITapGestureRecognizer *gesture2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:gesture1];
    [self.scrollView addGestureRecognizer:gesture2];
    self.passwordTextField.returnKeyType=UIReturnKeyGo;
    self.passwordTextField.enablesReturnKeyAutomatically=YES;
    [self changeLoginButtonState];
}

#pragma mark -实现UITextFieldDelegate协议
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self changeLoginButtonState];
    [self scrollviewScrollWithWidth:0 Height:70];
    self.scrollView.scrollEnabled=YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self changeLoginButtonState];
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
        self.loginButton.alpha=0.7;
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
    self.loginButton.alpha=0.7;
    self.loginButton.enabled=NO;
    return ;
}

#pragma mark - 点击登录按钮
- (IBAction)loginButtonPressed:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self doLogin];
}

#pragma mark - 发送登录信息
-(void)doLogin{
    [SVProgressHUD showWithStatus:@"请稍候..."];
    
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [LoginUtilities loginWithUserName:self.usernameTextField.text password:self.passwordTextField.text delegete:self];
}

#pragma mark - 隐藏键盘
-(void)hideKeyBoard{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self scrollviewScrollWithWidth:0 Height:0];
    self.scrollView.scrollEnabled=NO;
}

#pragma mark - 滑动scrollview
-(void)scrollviewScrollWithWidth:(NSInteger)width
                          Height:(NSInteger)height{
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset=CGPointMake(width, height);
    }];
}

#pragma mark - 实现LoginHttpResponseDelegate协议
-(void)handleLoginSuccessResponse:(id)response{
    [SVProgressHUD dismiss];
    RootViewController *controller=[RootViewController getInstance];
    [UIApplication sharedApplication].keyWindow.rootViewController=controller;
}
-(void)handleLoginErrorResponse:(id)response{
    [SVProgressHUD showErrorWithStatus:@"账号密码错误"];
}
@end
