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
#import "UserUtilities.h"
#import "LoginConfiguration.h"
#import "BBSConstants.h"
@interface SecondLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UISwitch *shouldSaveLoginConfiguration;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation SecondLoginViewController

-(void)viewDidLoad{
    self.loginButton.layer.cornerRadius=5.f;
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:kCustomGreenColor.red/255.f green:kCustomGreenColor.green/255.f blue :kCustomGreenColor.blue/255.f alpha:1]];
}
+(SecondLoginViewController*)getInstance{
    return [[SecondLoginViewController alloc]initWithNibName:@"LoginView" bundle:nil];
}
#pragma mark - 点击登录按钮
- (IBAction)loginButtonPressed:(id)sender {
    //[LoginUtilities doLogin:self.nameTextField.text password:self.passwdTextField.text saveLoginConfiguration:self.shouldSaveLoginConfiguration.isOn delegate:self];
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
