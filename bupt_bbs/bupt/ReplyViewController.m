//
//  ReplyViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/9.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "ReplyViewController.h"
#import "ArticleInfo.h"
#import "UserInfo.h"
#import "PostArticleUtilities.h"
#import "CustomUtilities.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomEmojiKeyboard.h"
#import "YYImage+Emoji.h"
#import "CustomYYAnimatedImageView.h"
#import "AttachmentUtilities.h"

#import <SVProgressHUD.h>
#import <Masonry.h>

#define kToolBarHeight 46+1
#define kToolBarItemHeight 46
#define kMargin 8

@interface ReplyViewController ()

@property (strong,nonatomic)NSString *boardName;
@property (strong,nonatomic)NSString *articleName;
@property (nonatomic)BOOL isNewTheme;
@property (nonatomic)int articleId;
@property (strong,nonatomic)ArticleInfo *articleInfo;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet YYTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UIButton *emojiButton;

@property (strong,nonatomic) UIView *dummyView;
@property (strong,nonatomic) CustomEmojiKeyboard *emojiKeyboard;

@end


@implementation ReplyViewController

+(instancetype)getInstanceWithBoardName:(NSString*)boardName
                             isNewTheme:(BOOL)isNewTheme
                        withArticleName:(NSString*)articleName
                          withArticleId:(int)articleId
                        withArticleInfo:(ArticleInfo*)articleInfo
{
    ReplyViewController *replyViewController=[[ReplyViewController alloc]initWithNibName:@"ReplyView" bundle:nil];
    
    replyViewController.boardName=boardName;
    replyViewController.articleName=articleName;
    replyViewController.isNewTheme=isNewTheme;
    replyViewController.articleId=articleId;
    replyViewController.articleInfo=articleInfo;
    
    return replyViewController;
}
-(void)loadView{
    [super loadView];
    
    [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(64);
        make.width.equalTo(self.view.mas_width).with.offset(-2*kMargin);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(36);
    }];
    [_seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleTextField.mas_bottom);
        make.width.equalTo(_titleTextField.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(CGFloatFromPixel(1));
    }];
    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_seperatorView.mas_bottom);
        make.width.equalTo(_titleTextField.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(self.view.mas_width).multipliedBy(0.6);
    }];
    [_toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(kToolBarHeight);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_pictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kToolBarItemHeight);
        make.height.mas_equalTo(kToolBarItemHeight);
        make.centerX.equalTo(_toolbar.mas_centerX).multipliedBy(0.5);
        make.centerY.equalTo(_toolbar.mas_centerY).with.offset(0.5);
    }];
    [_emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kToolBarItemHeight);
        make.height.mas_equalTo(kToolBarItemHeight);
        make.centerX.equalTo(_toolbar.mas_centerX).multipliedBy(1.5);
        make.centerY.equalTo(_toolbar.mas_centerY).with.offset(0.5);
    }];
    [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self _initNavigationItem];
    [self _initTitleTextField];
    [self _initSeperatorView];
    [self _initContentTextView];
    [self _initToolbar];
    
    _emojiKeyboard=[[CustomEmojiKeyboard alloc]init];
    _emojiKeyboard.delegate=self;
    
    if(_isNewTheme){
        [_titleTextField becomeFirstResponder];
    }
    else{
        [_contentTextView becomeFirstResponder];
        _contentTextView.selectedRange=NSMakeRange(0, 0);
    }
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化各个view
-(void)_initNavigationItem{
    if(!_isNewTheme){
        self.navigationItem.title=@"回复";
    }
    else{
        self.navigationItem.title=@"新话题";
    }
    UIBarButtonItem *postBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(postArticle)];
    [postBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem=postBarButtonItem;
}

-(void)_initTitleTextField{
    _titleTextField.font=[UIFont systemFontOfSize:16];
    //为了防止下面的内容view 滚动时 覆盖掉title
    _titleTextField.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_titleTextField];
    
    [_titleTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        
    }];
    if(!_isNewTheme){
        _titleTextField.text=[NSString stringWithFormat:@"Re:%@",_articleName];
    }
    else{
        _titleTextField.placeholder=@"在这里输入标题...";
    }
}

-(void)_initSeperatorView{
    _seperatorView.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
}

-(void)_initContentTextView{
    _contentTextView.showsVerticalScrollIndicator=NO;
    _contentTextView.allowsCopyAttributedString=NO;
    _contentTextView.textContainerInset=UIEdgeInsetsMake(12, 0, 0, 0);
    _contentTextView.font=[UIFont systemFontOfSize:17];
    _contentTextView.placeholderFont=[UIFont systemFontOfSize:17];
    _contentTextView.placeholderTextColor=[CustomUtilities getColor:@"B4B4B4"];
    
    if(!_isNewTheme){
        if(_articleInfo==nil){
            _contentTextView.placeholderText=@"在这里输入内容...";
        }
        else{
            NSRange range;
            range.location=0;
            if(_articleInfo.content.length>50){
                range.length=50;
            }
            else{
                range.length=_articleInfo.content.length;
            }
            NSMutableAttributedString *contenttext=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\n【在%@的大作中提到:】\n%@",_articleInfo.user.userId,[_articleInfo.content substringWithRange:range]]];
            contenttext.font=_contentTextView.font;
            _contentTextView.attributedText=contenttext;
        }
    }
    else{
        _contentTextView.placeholderText=@"在这里输入内容...";
    }
}
-(void)_initToolbar{
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolbar.frame), CGFloatFromPixel(1))];
    line.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbar addSubview:line];
    
    _toolbar.backgroundColor=[CustomUtilities getColor:@"F9F9F9"];
    [_pictureButton setImage:[UIImage imageNamed:@"toolbarpicture"] forState:UIControlStateNormal];
    [_pictureButton setImage:[UIImage imageNamed:@"toolbarpicturehighlighted"] forState:UIControlStateHighlighted];
    [_pictureButton addTarget:self action:@selector(choosePicture) forControlEvents:UIControlEventTouchUpInside];
    
    [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotion"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotionhighlighted"] forState:UIControlStateHighlighted];
    [_emojiButton addTarget:self action:@selector(showEmojiKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_toolbar];
}
#pragma mark - 发表
-(void)postArticle{
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
    NSLog(@"%@",contentString);
    NSString *message=nil;
    if(_isNewTheme)
        message=@"确认发表新话题？";
    else
        message=@"确认回复该话题？";
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"发表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self disableInteraction];
        [SVProgressHUD showWithStatus:@"发表中"];
        [PostArticleUtilities postArticleWithBoardName:_boardName withArticleTitle:_titleTextField.text withArticleContent:contentString isNewTheme:_isNewTheme withReplyArticleID:_articleId delegate:self];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 发表过程中开关别的控件响应
-(void)disableInteraction{
    if(!_dummyView){
        _dummyView=[[UIView alloc]initWithFrame:kCustomScreenBounds];
        _dummyView.backgroundColor=[UIColor clearColor];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_dummyView];
}
-(void)enableInteraction{
    [_dummyView removeFromSuperview];
    _dummyView=nil;
}
#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    [self enableInteraction];
    [SVProgressHUD showSuccessWithStatus:@"发表成功"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
-(void)handleHttpErrorResponse:(id)response{
    [self enableInteraction];
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


#pragma mark - 监听键盘相关通知
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *dic=notification.userInfo;
    CGRect frame=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat timeInterval=[[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger curve=[[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationCurve:curve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [_toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-CGRectGetHeight(frame));
        }];
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    NSDictionary *dic=notification.userInfo;
    CGFloat timeInterval=[[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    NSInteger curve=[[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey]integerValue];
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationCurve:curve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [_toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }];
}


#pragma mark - 显示图片选择
-(void)choosePicture{
//    NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"]];
//    [AttachmentUtilities postAttachmentWithBoardName:_boardName withNeedArticleID:NO withArticleID:0 withFileName:@"test.png" withFileType:@"image/png" withFileData:data delegate:nil];
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
@end
