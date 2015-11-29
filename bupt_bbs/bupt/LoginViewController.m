//
//  LogInViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/17.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginUtilities.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UISwitch *shouldSaveUserInfo;

@end

@implementation LoginViewController

#pragma mark - 点击登录按钮
- (IBAction)loginButtonPressed:(id)sender {
    [LoginUtilities doLogin:self.nameTextField.text password:self.passwdTextField.text saveUserInfo:self.shouldSaveUserInfo.isOn
                   delegate:self];
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

-(void)showHome{
    [UIApplication sharedApplication].keyWindow.rootViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
}
@end
