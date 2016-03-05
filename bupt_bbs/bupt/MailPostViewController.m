//
//  MailPostViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/25.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailPostViewController.h"
#import "CustomUtilities.h"
#import "CustomLinePositionModifier.h"
#import "ScreenAdaptionUtilities.h"
#import "QCEmojiKeyboard.h"
#import "QCEmojiKeyboardDelegate.h"
#import "CustomYYAnimatedImageView.h"
#import "YYImage+Emoji.h"
#import "HttpResponseDelegate.h"
#import "MailboxUtilities.h"

#import <SVProgressHUD.h>
#import <YYKit.h>
#import <Masonry.h>

#define kMargin 8
#define kLabelHeight 30
#define kIdAndTitleFontSize 14
#define kContentFontSize    17
#define kToolBarHeight 46+1
#define kToolBarItemHeight 46

@interface MailPostViewController ()<QCEmojiKeyboardDelegate,HttpResponseDelegate>

@property (nonatomic) BOOL isReply;
@property (copy,nonatomic) NSString* box_name;
@property (nonatomic) NSInteger index;
@property (copy,nonatomic) NSString* content;
@property (copy,nonatomic) NSString* userId;
@property (copy,nonatomic) NSString* mailTitle;

@property (strong,nonatomic)UIView *containerView;
@property (strong,nonatomic)UILabel *receiverIdLabel;
@property (strong,nonatomic)UITextField *receiverIdTextField;
@property (strong,nonatomic)UIView *seperatorView1;
@property (strong,nonatomic)UILabel *titleLabel;
@property (strong,nonatomic)UITextField *titleTextField;
@property (strong,nonatomic)UIView *seperatorView2;
@property (strong,nonatomic)YYTextView *contentTextView;
@property (strong,nonatomic)UIView *toolbar;
@property (strong,nonatomic)UIButton *emojiButton;

@property (strong,nonatomic)QCEmojiKeyboard *emojiKeyboard;
@end

@implementation MailPostViewController

+(instancetype)getInstanceWithIsReply:(BOOL)isReply
                          withBoxName:(NSString *)box_name
                       withReceiverId:(NSString *)userId
                            withTitle:(NSString *)mailTitle
                          withContent:(NSString *)content
                            withIndex:(NSInteger)index{
    MailPostViewController *controller=[[MailPostViewController alloc]init];
    controller.isReply=isReply;
    controller.box_name=box_name;
    controller.index=index;
    controller.content=content;
    controller.userId=userId;
    controller.mailTitle=mailTitle;
    return controller;
}

-(void)loadView{
    [super loadView];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    _contentTextView=[[YYTextView alloc]init];
    [self.view addSubview:_contentTextView];
    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _containerView=[[UIView alloc]init];
    _containerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(CGRectGetMaxY(self.navigationController.navigationBar.frame));
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
    }];
    
    _receiverIdLabel=[[UILabel alloc]init];
    _receiverIdLabel.text=@"收件人:";
    _receiverIdLabel.font=[UIFont systemFontOfSize:kIdAndTitleFontSize];
    _receiverIdLabel.textAlignment=NSTextAlignmentCenter;
    _receiverIdLabel.textColor=[UIColor blackColor];
    _receiverIdLabel.minimumScaleFactor=0.5;
    [_containerView addSubview:_receiverIdLabel];
    [_receiverIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_containerView.mas_top).with.offset(kMargin);
        make.leading.equalTo(_containerView.mas_leading).with.offset(kMargin);
        make.height.mas_equalTo(kLabelHeight);
        make.width.equalTo(_containerView.mas_width).multipliedBy(0.2);
    }];
    
    _receiverIdTextField=[[UITextField alloc]init];
    _receiverIdTextField.textColor=[UIColor blackColor];
    _receiverIdTextField.borderStyle=UITextBorderStyleNone;
    _receiverIdTextField.font=[UIFont systemFontOfSize:kIdAndTitleFontSize];
    [_containerView addSubview:_receiverIdTextField];
    [_receiverIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_receiverIdLabel.mas_trailing).with.offset(kMargin);
        make.top.equalTo(_receiverIdLabel.mas_top);
        make.trailing.equalTo(_containerView.mas_trailing).with.offset(-kMargin);
        make.height.equalTo(_receiverIdLabel.mas_height);
    }];
    
    _seperatorView1=[[UIView alloc]init];
    _seperatorView1.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
    [_containerView addSubview:_seperatorView1];
    [_seperatorView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_receiverIdLabel.mas_bottom);
        make.height.mas_equalTo(CGFloatFromPixel(1));
        make.leading.equalTo(_containerView.mas_leading).with.offset(kMargin);
        make.trailing.equalTo(_containerView.mas_trailing).with.offset(-kMargin);
    }];
    
    _titleLabel=[[UILabel alloc]init];
    _titleLabel.text=@"标题:";
    _titleLabel.font=[UIFont systemFontOfSize:kIdAndTitleFontSize];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.textColor=[UIColor blackColor];
    _titleLabel.minimumScaleFactor=0.5;
    [_containerView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_seperatorView1.mas_bottom).with.offset(kMargin);
        make.leading.equalTo(_receiverIdLabel.mas_leading);
        make.height.equalTo(_receiverIdLabel.mas_height);
        make.trailing.equalTo(_receiverIdLabel.mas_trailing);
    }];
    
    _titleTextField=[[UITextField alloc]init];
    _titleTextField.textColor=[UIColor blackColor];
    _titleTextField.borderStyle=UITextBorderStyleNone;
    _titleTextField.font=[UIFont systemFontOfSize:kIdAndTitleFontSize];
    [_containerView addSubview:_titleTextField];
    [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_receiverIdTextField.mas_leading);
        make.trailing.equalTo(_receiverIdTextField.mas_trailing);
        make.top.equalTo(_titleLabel.mas_top);
        make.height.equalTo(_titleLabel.mas_height);
    }];
    
    _seperatorView2=[[UIView alloc]init];
    _seperatorView2.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
    [_containerView addSubview:_seperatorView2];
    [_seperatorView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom);
        make.height.mas_equalTo(CGFloatFromPixel(1));
        make.leading.equalTo(_containerView.mas_leading).with.offset(kMargin);
        make.trailing.equalTo(_containerView.mas_trailing).with.offset(-kMargin);
        make.bottom.equalTo(_containerView.mas_bottom);
    }];
    
    _toolbar=[[UIView alloc]init];
    _toolbar.backgroundColor=[CustomUtilities getColor:@"F9F9F9"];
    [self.view addSubview:_toolbar];
    [_toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.mas_equalTo(kToolBarHeight);
    }];
   
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolbar.frame), CGFloatFromPixel(1))];
    line.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbar addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(CGFloatFromPixel(1));
        make.top.equalTo(_toolbar.mas_top);
        make.leading.equalTo(_toolbar.mas_leading);
        make.trailing.equalTo(_toolbar.mas_trailing);
    }];
    
    _emojiButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotion"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotionhighlighted"] forState:UIControlStateHighlighted];
    [_emojiButton addTarget:self action:@selector(showEmojiKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar addSubview:_emojiButton];
    [_emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kToolBarItemHeight);
        make.width.mas_equalTo(kToolBarItemHeight);
        make.centerX.equalTo(_toolbar.mas_centerX);
        make.top.equalTo(line.mas_bottom);
    }];
    
    [self.view addSubview:_toolbar];
    [self.view layoutIfNeeded];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self _initNavigationItem];
    [self _initReceiverTextField];
    [self _initTitleTextField];
    [self _initContentTextview];

    if(!_isReply){
        [_receiverIdTextField becomeFirstResponder];
    }
    else{
        [_contentTextView becomeFirstResponder];
        _contentTextView.selectedRange=NSMakeRange(0, 0);
    }
    
    _emojiKeyboard=[[QCEmojiKeyboard alloc]init];
    _emojiKeyboard.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 初始化导航栏
-(void)_initNavigationItem{
    if(!_isReply){
        self.navigationItem.title=@"新信件";
    }
    else{
        self.navigationItem.title=@"回复信件";
    }
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(postMail)];
    self.navigationItem.rightBarButtonItem=barButtonItem;
}


#pragma mark - 初始化ReceiverTextField
-(void)_initReceiverTextField{
    if(_isReply){
        _receiverIdTextField.text=_userId;
    }
}

#pragma mark - 初始化TitleTextField
-(void)_initTitleTextField{
    if(_isReply){
        _titleTextField.text=[NSString stringWithFormat:@"Re:%@",_mailTitle];
    }
}

#pragma mark - 初始化ContentTextView
-(void)_initContentTextview{
    _contentTextView.showsVerticalScrollIndicator=NO;
    _contentTextView.allowsCopyAttributedString=NO;
    _contentTextView.contentInset=UIEdgeInsetsMake(CGRectGetMaxY(_containerView.frame)-CGRectGetHeight(self.navigationController.navigationBar.frame)-CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, CGRectGetHeight(_toolbar.frame), 0);
    _contentTextView.textContainerInset=UIEdgeInsetsMake(12, kMargin, 12, kMargin);
    _contentTextView.font=[UIFont systemFontOfSize:17];
    _contentTextView.placeholderFont=[UIFont systemFontOfSize:17];
    _contentTextView.placeholderTextColor=[CustomUtilities getColor:@"B4B4B4"];
    _contentTextView.extraAccessoryViewHeight=kToolBarHeight;
    
    CustomLinePositionModifier *modifier = [CustomLinePositionModifier new];
    modifier.font = [UIFont systemFontOfSize:17];
    modifier.paddingTop = 12;
    modifier.paddingBottom = 12;
    modifier.lineHeightMultiple = 1.5;
    _contentTextView.linePositionModifier = modifier;
    
    if(_isReply){
        NSRange range;
        range.location=0;
        if(_content.length>50){
            range.length=50;
        }
        else{
            range.length=_content.length;
        }
        NSMutableAttributedString *contenttext=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\n【在%@的大作中提到:】\n%@",_userId,[_content substringWithRange:range]]];
        contenttext.font=_contentTextView.font;
        _contentTextView.attributedText=contenttext;
    }
    else{
        _contentTextView.placeholderText=@"在这里输入信件内容...";
    }
}


#pragma mark - 发送信件
-(void)postMail{
    NSMutableString *contentString=[[NSMutableString alloc]init];
    for(int i=0;i<_contentTextView.attributedText.length;i++){
        if([_contentTextView.attributedText attribute:YYTextAttachmentAttributeName atIndex:i]){
            YYTextAttachment *attachment=[_contentTextView.attributedText attribute:YYTextAttachmentAttributeName atIndex:i];
            CustomYYAnimatedImageView *imageView=attachment.content;
            [contentString appendString:imageView.imageString];
        }
        else
            [contentString appendString:[_contentTextView.text substringWithRange:NSMakeRange(i, 1)]];
    }
    
    NSString *message=nil;
    if(_isReply)
        message=@"确认回复信件？";
    else
        message=@"确认发送信件？";
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"信件投递中..."];
        if(!_isReply){
            [MailboxUtilities postNewMailWithUserId:_receiverIdTextField.text withTitle:_titleTextField.text withContent:contentString withSignature:0 withbackup:0 withDelegate:self];
        }
        else{
            [MailboxUtilities postReplyMailWithBoxName:_box_name withIndex:_index withTitle:_titleTextField.text withContent:contentString withSignature:0 withbackup:0 withDelegate:self];
        }
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - 显示表情键盘
-(void)showEmojiKeyboard{
    if(_contentTextView.inputView==_emojiKeyboard){
        _contentTextView.inputView=nil;
        [_contentTextView reloadInputViews];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotion"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotionhighlighted"] forState:UIControlStateHighlighted];
    }
    else{
        _contentTextView.inputView=_emojiKeyboard;
        [_contentTextView reloadInputViews];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbarkeyboard"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbarkeyboardhighlighted"] forState:UIControlStateHighlighted];
        
        if(![_contentTextView isFirstResponder])
            [_contentTextView becomeFirstResponder];
    }
}

#pragma mark - 实现CustomEmojiKeyboardDelegate
-(void)addEmojiWithImage:(YYImage *)image withImageString:(NSString *)imageString{
    UIFont*font=_contentTextView.font;
    CGFloat imageViewWidth=font.ascender-font.descender+6;
    CustomYYAnimatedImageView *imageview=[[CustomYYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewWidth)];
    imageview.imageString=imageString;
    
    NSRange range;
    range.location=1;
    range.length=imageString.length-2;
    imageview.image=[YYImage imageNamedFromEmojiBundle:[imageString substringWithRange:range]];
    NSMutableAttributedString *tmp=[NSMutableAttributedString attachmentStringWithContent:imageview contentMode:UIViewContentModeCenter attachmentSize:imageview.frame.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    tmp.font=font;
    
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]initWithAttributedString:_contentTextView.attributedText];
    NSRange selectedRange=_contentTextView.selectedRange;
    [res replaceCharactersInRange:selectedRange  withAttributedString:tmp];
    _contentTextView.attributedText=res;
    
    selectedRange.location++;
    _contentTextView.selectedRange=selectedRange;
}

-(void)deleteEmoji{
    [_contentTextView deleteBackward];
}


#pragma mark - 监听键盘相关通知
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *dic=notification.userInfo;
    CGRect frame=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat timeInterval=[[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger curve=[[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [_toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-CGRectGetHeight(frame));
    }];
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationCurve:curve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    NSDictionary *dic=notification.userInfo;
    CGFloat timeInterval=[[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    NSInteger curve=[[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey]integerValue];
    [_toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationCurve:curve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    [SVProgressHUD showSuccessWithStatus:@"信件发送成功"];
}

-(void)handleHttpErrorResponse:(id)response{
    NSError *error=(NSError *)response;
    NetworkErrorCode errorCode=[CustomUtilities getNetworkErrorCode:error];
    switch (errorCode) {
        case NetworkConnectFailed:
            [SVProgressHUD showErrorWithStatus:@"网络连接已断开"];
            break;
        case NetworkConnectTimeout:
            [SVProgressHUD showErrorWithStatus:@"网络连接超时"];
            break;
        case NetworkConnectUnknownReason:
            [SVProgressHUD showErrorWithStatus:@"好像出现了某种奇怪的问题"];
            break;
        default:
            break;
    }
}
@end
