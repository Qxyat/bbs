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
#import <Masonry.h>
@interface JumpPopoverController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
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
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
        make.top.equalTo(self.view.mas_bottom);
    }];
    [self.noImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView.mas_trailing).multipliedBy(0.1);
        make.centerY.equalTo(self.containerView.mas_centerY).multipliedBy(0.5);
        make.height.equalTo(self.containerView.mas_height).multipliedBy(0.5);
        make.width.equalTo(self.containerView.mas_width).multipliedBy(0.1);
    }];
    [self.firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView.mas_trailing).multipliedBy(0.3);
        make.bottom.equalTo(self.containerView.mas_centerY);
        make.width.equalTo(self.containerView.mas_width).multipliedBy(0.05);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(self.firstLabel.mas_baseline);
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.width.equalTo(self.containerView.mas_width).multipliedBy(0.3);
    }];
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.containerView.mas_width).multipliedBy(0.05);
        make.baseline.equalTo(self.firstLabel.mas_baseline);
        make.leading.equalTo(self.containerView.mas_trailing).multipliedBy(0.65);
    }];
    [self.yesImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView.mas_trailing).multipliedBy(0.8);
        make.height.equalTo(self.noImageView.mas_height);
        make.centerY.equalTo(self.noImageView.mas_centerY);
        make.width.equalTo(self.noImageView.mas_width);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.bottom.equalTo(self.containerView.mas_bottom);
        make.width.equalTo(self.containerView.mas_width).multipliedBy(0.3);
    }];
    [self.view layoutIfNeeded];
    
    
    UITapGestureRecognizer *recognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideJumpPopoverController)];
    [self.noImageView addGestureRecognizer:recognizer1];
    
    UITapGestureRecognizer *recognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToPage)];
    [self.yesImageView addGestureRecognizer:recognizer2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.infoLabel.text=[NSString stringWithFormat:@"当前%d/%d页",self.page_cur_count,self.page_all_count];
    
    
    self.textField.delegate=self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textField becomeFirstResponder];
    });
}
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *dic=[notification userInfo];
    CGRect keyboardRect=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    
    NSNumber *duration=[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve=[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        CGFloat bottomY=self.view.frame.size.height-keyboardRect.size.height;
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view.mas_leading);
            make.trailing.equalTo(self.view.mas_trailing);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
            make.bottom.equalTo(self.view.mas_top).with.offset(bottomY);
        }];
    }];
    [self.view layoutIfNeeded];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    NSDictionary *dic=[notification userInfo];
    NSNumber *duration=[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve=[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view.mas_leading);
            make.trailing.equalTo(self.view.mas_trailing);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
            make.top.equalTo(self.view.mas_bottom);
        }];

    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    [self.view layoutIfNeeded];
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
