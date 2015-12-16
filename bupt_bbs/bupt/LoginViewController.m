//
//  LogInViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginUtilities.h"
#import "RootViewController.h"
#import "UserUtilities.h"
#import "LoginConfiguration.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UISwitch *shouldSaveLoginConfiguration;

@end

@implementation LoginViewController
+(LoginViewController*)getInstance{
    return [[LoginViewController alloc]initWithNibName:@"LoginView" bundle:nil];
}
#pragma mark - 点击登录按钮
- (IBAction)loginButtonPressed:(id)sender {
    [LoginUtilities doLogin:self.nameTextField.text password:self.passwdTextField.text saveLoginConfiguration:self.shouldSaveLoginConfiguration.isOn delegate:self];
}

#pragma mark - 点击背景，释放输入框
- (IBAction)backgroundTap:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self.passwdTextField resignFirstResponder];
}

#pragma mark - 完成输入
- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}


#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
    [UserUtilities getLoginUserInfo:self];
}
-(void)handleUserInfoResponse:(id)response{
    [LoginConfiguration getInstance].loginUserInfo=[UserInfo getUserInfo:response];
    [UIApplication sharedApplication].keyWindow.rootViewController=[RootViewController getInstance];
}
@end
