//
//  JumpPopoverController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/3.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "JumpPopoverController.h"
#import "ScreenAdaptionUtilities.h"
#import <SVProgressHUD.h>
@interface JumpPopoverController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yesImageView;

@end
@implementation JumpPopoverController
+(instancetype)getInstance{
    return [[JumpPopoverController alloc]initWithNibName:@"JumpPopoverControllerView" bundle:nil];
}
-(void)loadView{
    [super loadView];
    CGFloat y=self.navigationBarHeight+kCustomStatusBarHeight;
    self.view.frame=CGRectMake(0, y,kCustomScreenWidth, kCustomScreenHeight-y);
    [self.view layoutIfNeeded];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    UITapGestureRecognizer *recognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideJumpPopoverController)];
    [self.noImageView addGestureRecognizer:recognizer1];
    
    UITapGestureRecognizer *recognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToPage)];
    [self.yesImageView addGestureRecognizer:recognizer2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.infoLabel.text=[NSString stringWithFormat:@"当前%d/%d页",self.page_cur_count,self.page_all_count];
    [self.textField becomeFirstResponder];
    
    self.textField.delegate=self;
}
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *dic=[notification userInfo];
    CGRect keyboardRect=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardEndy=keyboardRect.origin.y;
    NSNumber *duration=[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve=[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        CGFloat centerY=keyboardEndy-self.navigationBarHeight-[UIApplication sharedApplication].statusBarFrame.size.height-self.containerView.frame.size.height/2;
        self.containerView.center=CGPointMake(self.containerView.center.x,centerY) ;
    }];
}
-(void)keyboardWillHide:(NSNotification*)notification{
    NSDictionary *dic=[notification userInfo];
    CGRect keyboardRect=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardEndy=keyboardRect.origin.y;
    NSNumber *duration=[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve=[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        CGFloat centerY=keyboardEndy-self.navigationBarHeight-[UIApplication sharedApplication].statusBarFrame.size.height+self.containerView.frame.size.height/2;
        self.containerView.center=CGPointMake(self.containerView.center.x, centerY);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}
-(void)hideJumpPopoverController{
    [self.delegate hideJumpPopoverController];
}
-(void)hideJumpPopoverControllerView{
    [self.textField resignFirstResponder];
}
-(void)jumpToPage{
    NSString *string=self.textField.text;
    NSInteger page=[string intValue];
    if(page<1||page>self.page_all_count){
        [SVProgressHUD showInfoWithStatus:@"页码错误请重新输入"];
        return;
    }
    [self.delegate jumpToRefresh:page];
}
#pragma mark - 实现UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self jumpToPage];
    return YES;
}
@end
