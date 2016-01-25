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
@property (nonatomic) CGRect frame;
@property (weak,nonatomic) id<JumpPopoverControllerDelegate>delegate;
@property (nonatomic) NSInteger page_all_count;
@property (nonatomic) NSInteger page_cur_count;

@property (strong, nonatomic)  UIView *containerView;
@property (strong, nonatomic)  UITextField *textField;
@property (strong, nonatomic)  UILabel *infoLabel;
@property (strong, nonatomic)  UIButton *noButton;
@property (strong, nonatomic)  UILabel *firstLabel;
@property (strong, nonatomic)  UILabel *secondLabel;
@property (strong, nonatomic)  UIButton *yesButton;

@end

@implementation JumpPopoverController
+(instancetype)getInstanceWithFrame:(CGRect)frame
                   withPageAllCount:(NSInteger)page_all_count
                   withPageCurCount:(NSInteger)page_cur_count
                       withDelegate:(id<JumpPopoverControllerDelegate>)delegate
{
    JumpPopoverController *controller=[[JumpPopoverController alloc]init];
    controller.frame=frame;
    controller.delegate=delegate;
    controller.page_all_count=page_all_count;
    controller.page_cur_count=page_cur_count;
    
    return controller;
}
-(void)loadView{
    [super loadView];
    self.view.frame=_frame;
    self.view.backgroundColor=[UIColor clearColor];
    
    _containerView=[[UIView alloc]init];
    _containerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
        make.top.equalTo(self.view.mas_bottom);
    }];
    
    _noButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_noButton setBackgroundImage:[UIImage imageNamed:@"btn_no_n"] forState:UIControlStateNormal];
    [_noButton setBackgroundImage:[UIImage imageNamed:@"btn_no_h"] forState:UIControlStateHighlighted];
    [_noButton addTarget:self action:@selector(hideJumpPopoverController) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_noButton];
    [_noButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.1);
        make.centerY.equalTo(_containerView.mas_centerY).multipliedBy(0.5);
        make.height.equalTo(_containerView.mas_height).multipliedBy(0.5);
        make.width.equalTo(_containerView.mas_height).multipliedBy(0.5);
    }];
    
    _firstLabel=[[UILabel alloc]init];
    _firstLabel.font=[UIFont systemFontOfSize:15];
    _firstLabel.textColor=[UIColor blackColor];
    _firstLabel.textAlignment=NSTextAlignmentCenter;
    _firstLabel.text=@"第";
    [_containerView addSubview:_firstLabel];
    [_firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.3);
        make.bottom.equalTo(_containerView.mas_centerY);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.05);
    }];
    
    _textField=[[UITextField alloc]init];
    _textField.font=[UIFont systemFontOfSize:15];
    _textField.borderStyle=UITextBorderStyleNone;
    _textField.textColor=[UIColor blackColor];
    _textField.textAlignment=NSTextAlignmentCenter;
    _textField.keyboardType=UIKeyboardTypeNumberPad;
    [_containerView addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(_firstLabel.mas_baseline);
        make.centerX.equalTo(_containerView.mas_centerX);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.3);
    }];
    
    _secondLabel=[[UILabel alloc]init];
    _secondLabel.font=[UIFont systemFontOfSize:15];
    _secondLabel.textColor=[UIColor blackColor];
    _secondLabel.textAlignment=NSTextAlignmentCenter;
    _secondLabel.text=@"页";
    [_containerView addSubview:_secondLabel];
    [_secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.05);
        make.baseline.equalTo(_firstLabel.mas_baseline);
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.65);
    }];
    
    _yesButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_yesButton setBackgroundImage:[UIImage imageNamed:@"btn_yes_n"] forState:UIControlStateNormal];
    [_yesButton setBackgroundImage:[UIImage imageNamed:@"btn_yes_h"] forState:UIControlStateHighlighted];
    [_yesButton addTarget:self action:@selector(jumpToPage) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_yesButton];
    [_yesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_trailing).multipliedBy(0.8);
        make.height.equalTo(_noButton.mas_height);
        make.centerY.equalTo(_noButton.mas_centerY);
        make.width.equalTo(_noButton.mas_width);
    }];
    
    _infoLabel=[[UILabel alloc]init];
    _infoLabel.font=[UIFont systemFontOfSize:12];
    _infoLabel.textColor=[UIColor blackColor];
    _infoLabel.textAlignment=NSTextAlignmentCenter;
    _infoLabel.minimumScaleFactor=0.5;
    [_containerView addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_containerView.mas_centerX);
        make.bottom.equalTo(_containerView.mas_bottom);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.3);
    }];
    
    [self.view layoutIfNeeded];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _infoLabel.text=[NSString stringWithFormat:@"当前%d/%d页",_page_cur_count,_page_all_count];
    _textField.delegate=self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_textField becomeFirstResponder];
    });
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *dic=[notification userInfo];
    CGRect keyboardRect=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *duration=[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve=[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGFloat bottomY= CGRectGetHeight(self.view.frame)-CGRectGetHeight(keyboardRect);
    [_containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
        make.bottom.equalTo(self.view.mas_top).with.offset(bottomY);
    }];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    NSDictionary *dic=[notification userInfo];
    NSNumber *duration=[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve=[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    [_containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
        make.top.equalTo(self.view.mas_bottom);
    }];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
}

-(void)hideJumpPopoverController{
    [_delegate hideJumpPopoverController];
}

-(void)hideJumpPopoverControllerView{
    [_textField resignFirstResponder];
}

-(void)jumpToPage{
    NSString *string=_textField.text;
    NSInteger page=[string intValue];
    if(page<1||page>_page_all_count){
        [SVProgressHUD showInfoWithStatus:@"页码错误请重新输入"];
        return;
    }
    [_delegate jumpToRefresh:page];
}

#pragma mark - 实现UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self jumpToPage];
    return YES;
}
@end
