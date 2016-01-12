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

#import <YYKit.h>
#import <SVProgressHUD.h>
#import <Masonry.h>
@interface ReplyViewController ()

@property (strong,nonatomic)NSString *boardName;
@property (strong,nonatomic)NSString *articleName;
@property (nonatomic)BOOL isNewTheme;
@property (nonatomic)int articleId;
@property (strong,nonatomic)ArticleInfo *articleInfo;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet YYTextView *contentTextField;
@property (strong,nonatomic) UIView *dummyView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
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
    
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(64);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.1);
    }];
    [self.seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleTextField.mas_bottom);
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(1);
    }];
    [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.seperatorView.mas_bottom);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.6);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.1);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.centerY.equalTo(self.containerView.mas_centerY);
    }];
    [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.dummyView=[[UIView alloc]initWithFrame:kCustomScreenBounds];
    self.dummyView.backgroundColor=[UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if(!self.isNewTheme){
        self.navigationItem.title=@"回复";
        self.titleTextField.text=[NSString stringWithFormat:@"Re:%@",self.articleName];
        if(self.articleInfo==nil){
            self.contentTextField.attributedText=[[NSAttributedString alloc]initWithString:@"在这输入内容"];
        }
        else{
            NSRange range;
            range.location=0;
            if(self.articleInfo.content.length>50){
                range.length=50;
            }
            else{
                range.length=self.articleInfo.content.length;
            }
            self.contentTextField.attributedText=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\n【在%@的大作中提到：】\n%@",self.articleInfo.user.userId,[self.articleInfo.content substringWithRange:range]]];
        }
        [self.contentTextField becomeFirstResponder];
    }
    else{
        self.navigationItem.title=@"新话题";
        self.titleTextField.placeholder=@"在这输入标题";
        self.contentTextField.placeholderText=@"在这输入内容";
        [self.titleTextField becomeFirstResponder];
    }
    self.contentTextField.font=[UIFont systemFontOfSize:14];
    
//    UIBarButtonItem *postBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(postArticle)];
//    self.navigationItem.rightBarButtonItem=postBarButtonItem;
    
    UITapGestureRecognizer *tapGestureRecognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showEmojiKeyboard)];
    [self.emojiLabel addGestureRecognizer:tapGestureRecognizer1];
    
    self.emojiKeyboard=[[CustomEmojiKeyboard alloc]init];
    self.emojiKeyboard.delegate=self;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)postArticle{
    [self disableInteraction];
    [SVProgressHUD showWithStatus:@"发表中"];
    [PostArticleUtilities postArticleWithBoardName:self.boardName withArticleTitle:self.titleTextField.text withArticleContent:self.contentTextField.text isNewTheme:self.isNewTheme withReplyArticleID:self.articleId delegate:self];
}
#pragma mark - 发表过程中开关别的控件响应
-(void)disableInteraction{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.dummyView];
}
-(void)enableInteraction{
    [self.dummyView removeFromSuperview];
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
        
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-CGRectGetHeight(frame));
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.1);
            make.centerX.equalTo(self.view.mas_centerX);
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
        
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.1);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }];
}

#pragma mark - 显示表情键盘
-(void)showEmojiKeyboard{
    if(self.contentTextField.inputView==self.emojiKeyboard){
        self.contentTextField.inputView=nil;
        [self.contentTextField reloadInputViews];
    }
    else{
        self.contentTextField.inputView=self.emojiKeyboard;
        [self.contentTextField reloadInputViews];
        if(![self.contentTextField isFirstResponder])
            [self.contentTextField becomeFirstResponder];
    }
}
#pragma mark - 实现CustomEmojiKeyboardDelegate
-(void)addEmojiWithImage:(YYImage *)image withImageString:(NSString *)imageString{
    NSLog(@"%@",imageString);
}
-(void)deleteEmoji{
    NSLog(@"deleteEmoji");
}
@end
