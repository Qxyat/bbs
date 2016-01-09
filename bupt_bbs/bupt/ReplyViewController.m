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
#import <YYKit.h>
#import <SVProgressHUD.h>
@interface ReplyViewController ()

@property (strong,nonatomic)NSString *boardName;
@property (strong,nonatomic)NSString *articleName;
@property (nonatomic)BOOL isNewTheme;
@property (nonatomic)int articleId;
@property (strong,nonatomic)ArticleInfo *articleInfo;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet YYTextView *contentTextField;
@property (strong,nonatomic) UIView *dummyView;
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
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.dummyView=[[UIView alloc]initWithFrame:kCustomScreenBounds];
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
            self.contentTextField.attributedText=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\n【在%@的大作中提到：】%@",@"123",[self.articleInfo.content substringWithRange:range]]];
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
    
    UIBarButtonItem *postBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(postArticle)];
    self.navigationItem.rightBarButtonItem=postBarButtonItem;
    
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
@end
