//
//  MailReadViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/22.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailReadViewController.h"
#import "MailboxUtilities.h"
#import "HttpResponseDelegate.h"
#import "CustomUtilities.h"
#import "MailInfo.h"
#import "DownloadResourcesUtilities.h"
#import "UserInfo.h"
#import "YYImage+Emoji.h"
#import "AttachmentInfo.h"
#import "ScreenAdaptionUtilities.h"
#import "AttachmentFile.h"
#import "UIBarButtonItem+Image.h"
#import "CustomPopoverController.h"
#import "MailPostViewController.h"
#import "UserInfo.h"
#import "MailHttpResponseDelegate.h"

#import <SVProgressHUD.h>
#import <YYKit.h>
#import <Masonry.h>

#define kMargin 8
#define kFaceImageViewWidth 50
static CGFloat const kContentFontSize=15;

@interface MailReadViewController ()<MailHttpResponseDelegate,CustomPopoverControllerDelegate>
@property (strong, nonatomic)  UIView *containerView;
@property (strong, nonatomic)  YYAnimatedImageView *faceImageView;
@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UILabel *useridLabel;
@property (strong, nonatomic)  UILabel *posttimeLabel;

@property (strong, nonatomic)  UIView *seperatorView;

@property (strong, nonatomic)  YYTextView *contentTextView;

@property (nonatomic) NSInteger index;
@property (copy,nonatomic) NSString* box_name;
@property (strong,nonatomic) MailInfo *maildata;

@property (strong,nonatomic)CustomPopoverController *customPopoverController;

@end

@implementation MailReadViewController

+(instancetype)getInstanceWithMailBoxName:(NSString*)box_name
                                withIndex:(NSInteger)index{
    MailReadViewController *controller=[[MailReadViewController alloc]init];
    controller.box_name=box_name;
    controller.index=index;
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
    [self.view addSubview:_containerView];
    _containerView.backgroundColor=[UIColor whiteColor];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(CGRectGetHeight(self.navigationController.navigationBar.frame)+CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
    }];
    
    _faceImageView=[[YYAnimatedImageView alloc]init];
    _faceImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_containerView addSubview:_faceImageView];
    [_faceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_containerView.mas_top).with.offset(kMargin);
        make.leading.equalTo(_containerView.mas_leading).with.offset(kMargin);
        make.width.mas_equalTo(kFaceImageViewWidth);
        make.height.mas_equalTo(kFaceImageViewWidth);
    }];
    
    _titleLabel=[[UILabel alloc]init];
    _titleLabel.font=[UIFont systemFontOfSize:17];
    _titleLabel.textAlignment=NSTextAlignmentLeft;
    _titleLabel.numberOfLines=0;
    [_containerView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_faceImageView.mas_trailing).with.offset(kMargin);
        make.trailing.equalTo(_containerView.mas_trailing).with.offset(-kMargin);
        make.top.equalTo(_containerView.mas_top).with.offset(kMargin);
        make.centerY.equalTo(_faceImageView.mas_centerY);
    }];
    
    _useridLabel=[[UILabel alloc]init];
    _useridLabel.font=[UIFont systemFontOfSize:12];
    _useridLabel.textAlignment=NSTextAlignmentCenter;
    _useridLabel.numberOfLines=1;
    _useridLabel.minimumScaleFactor=0.5;
    [_containerView addSubview:_useridLabel];
    [_useridLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_faceImageView.mas_leading);
        make.trailing.equalTo(_faceImageView.mas_trailing);
    }];
    
    _posttimeLabel=[[UILabel alloc]init];
    _posttimeLabel.font=[UIFont systemFontOfSize:12];
    _posttimeLabel.textAlignment=NSTextAlignmentLeft;
    _posttimeLabel.numberOfLines=1;
    _posttimeLabel.minimumScaleFactor=0.5;
    [_containerView addSubview:_posttimeLabel];
    [_posttimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleLabel.mas_leading);
        make.trailing.equalTo(_titleLabel.mas_trailing);
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(kMargin);
        make.bottom.equalTo(_containerView.mas_bottom).with.offset(-kMargin);
        make.top.equalTo(_useridLabel.mas_top);
        make.bottom.equalTo(_useridLabel.mas_bottom);
    }];
    
    _seperatorView=[[UIView alloc]init];
    _seperatorView.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
    [self.view addSubview:_seperatorView];
    [_seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).with.offset(kMargin);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-kMargin);
        make.top.equalTo(_containerView.mas_bottom);
        make.height.mas_equalTo(CGFloatFromPixel(1));
    }];
    
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavigationItem];
    [self _initContentTextView];
    
    [self _getMailData];
}


#pragma mark - 初始化navigationitem
-(void)_initNavigationItem{
    NSArray* selectItems=@[@"收件箱",@"发件箱",@"回收站"];
    NSArray* items=@[@"inbox",@"outbox",@"deleted"];
    
    for(int i=0;i<items.count;i++)
        if([items[i] isEqualToString:_box_name]){
            self.navigationItem.title=selectItems[i];
            break;
        }
    
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem getInstanceWithNormalImage:[UIImage imageNamed:@"btn_more_n"] withHighlightedImage:[UIImage imageNamed:@"btn_more_h"] target:self action:@selector(showCustomPopoverController)];
}


#pragma mark - 初始化contentTextView
-(void)_initContentTextView{
    _contentTextView.editable=NO;
    _contentTextView.showsVerticalScrollIndicator=NO;
   
    CGFloat offset=CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)+CGRectGetHeight(self.navigationController.navigationBar.frame);
   _contentTextView.contentInset=UIEdgeInsetsMake(offset, 0, 0, 0);
    _contentTextView.textContainerInset=UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
}


#pragma mark - 请求信件数据
- (void)_getMailData{
    [SVProgressHUD showWithStatus:@"信件加载中"];
    [MailboxUtilities getMailWithMailbox:_box_name withIndex:_index withDelegate:self];
}


#pragma mark - 显示PopoverController
-(void)showCustomPopoverController{
    if(_customPopoverController==nil){
        CGFloat yOffset=CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGRect frame=CGRectMake(0, yOffset, kCustomScreenWidth,kCustomScreenHeight-yOffset);
        NSArray *itemNames=@[@"回复",@"转寄",@"删除"];
        NSArray *pictures=@[@{CustomPopoverControllerImageTypeNormal:@"btn_replymail_n",CustomPopoverControllerImageTypeHighlighted: @"btn_replymail_h"},@{CustomPopoverControllerImageTypeNormal:@"btn_forward_n",CustomPopoverControllerImageTypeHighlighted:@"btn_forward_h"},@{CustomPopoverControllerImageTypeNormal:@"btn_delete_n",CustomPopoverControllerImageTypeHighlighted:@"btn_delete_h"}];
        _customPopoverController=[CustomPopoverController getInstanceWithFrame:frame withItemNames:itemNames withItemPictures:pictures withDelegate:self];
        [self.view addSubview:_customPopoverController.view];
    }
    else{
        [self hideCustomPopoverController];
    }

}

#pragma mark - 实现CustomPopoverControllerDelegate协议
-(void)hideCustomPopoverController{
    if(_customPopoverController!=nil){
        [_customPopoverController hideCustomPopoverControllerView];
        _customPopoverController=nil;
    }
}
-(void)itemTapped:(NSInteger)index{
    [self hideCustomPopoverController];
    if(index==0){
        NSString *userId;
        if(_maildata.isUserExist){
            UserInfo* userinfo=_maildata.user;
            userId=userinfo.userId;
        }
        else{
            userId=_maildata.user;
        }
        MailPostViewController* mailPostViewController=[MailPostViewController getInstanceWithIsReply:YES       withBoxName:_box_name withReceiverId:userId     withTitle:_maildata.title withContent:_maildata.content withIndex:_maildata.index];
        [self.navigationController pushViewController:mailPostViewController animated:YES];
    }
    else if(index==1){
        UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"转寄信件" message:@"请输入接收人的ID" preferredStyle:UIAlertControllerStyleAlert];
        [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder=@"请输入用户ID";
        }];
        UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action2=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textfield=controller.textFields.firstObject;
            [SVProgressHUD showWithStatus:@"转寄中"];
            [MailboxUtilities forwardMailWithBoxName:_box_name withIndex:_index withTarget:textfield.text withNoansi:0 withBig5:0 withDelegate:self];
        }];
        [controller addAction:action1];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if(index==2){
        UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"删除信件" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action2=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SVProgressHUD showWithStatus:@"删除中"];
            [MailboxUtilities deleteMailWithBoxName:_box_name withIndex:_index withDelegate:self];
        }];
        [controller addAction:action1];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - 刷新界面，显示数据
-(void)_refreshView{
    typeof(self) _wkself=self;
    
    if(_maildata.isUserExist){
        UserInfo *user=(UserInfo*)_maildata.user;
        YYImage *cachedImage=[DownloadResourcesUtilities downloadImage:user.face_url FromBBS:NO Completed:^(YYImage *image) {
            _wkself.faceImageView.image=image;
            if(image.animatedImageType==YYImageTypeGIF){
                [_wkself.faceImageView startAnimating];
            }
        }];
        if(cachedImage){
            _faceImageView.image=cachedImage;
            if(cachedImage.animatedImageType==YYImageTypeGIF){
                [_faceImageView startAnimating];
            }
        }
        _useridLabel.text=user.userId;
    }
    else{
        _faceImageView.image=[YYImage imageNamed:@"face_default"];
        _useridLabel.text=_maildata.user;
    }
    
    _titleLabel.text=_maildata.title;
    _posttimeLabel.text=[CustomUtilities getPostTimeString:_maildata.post_time];
    _contentTextView.attributedText=[self getAttributedStringWithArticle:_maildata fontColor:[UIColor blackColor] fontSize:kContentFontSize];
}


#pragma mark - 实现MailHttpResponseDelegate协议
-(void)handleMailInfoSuccessResponse:(id)response{
    [SVProgressHUD dismiss];
    _maildata=[MailInfo getMailInfo:response];
    [self _refreshView];
}

-(void)handleMailInfoErrorResponseWithError:(NSError *)error withResponse:(id)response{
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
-(void)handleMailForwardSuccessResponse:(id)response{
    [SVProgressHUD showSuccessWithStatus:@"转寄成功"];
}
-(void)handleMailForwardErrorResponseWithError:(NSError *)error withResponse:(id)response{
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

-(void)handleMailDeleteSuccessResponse:(id)response{
    [SVProgressHUD showSuccessWithStatus:@"删除成功"];
}
-(void)handleMailDeleteErrorResponseWithError:(NSError *)error withResponse:(id)response{
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


#pragma mark - 根据表情代码获得表情对应的AttributedString
-(NSAttributedString*)getEmoji:(NSString*)string
                  withFontSize:(CGFloat)fontSize
{
    UIFont* font=[UIFont systemFontOfSize:fontSize];
    CGFloat imageWidth=font.ascender-font.descender+10;
    
    YYAnimatedImageView *imageView=[[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
    imageView.image=[YYImage imageNamedFromEmojiBundle:string];
    
    //使用YYKit提供的方法，后期争取能替换成自己的
    NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    
    return attachText;
}

#pragma mark - 通过递归的方式获取对应的attributedstring
-(NSMutableAttributedString*)
getAttributedStringByRecursiveWithString:(NSString*)string
fontColor:(UIColor*)color
fontSize:(CGFloat) size
isBold:(BOOL)isBold
withAttachmentInfo:(AttachmentInfo*)
attachmentInfo
withAttachmentUsedInfo:(NSMutableArray*)used
{
    NSMutableAttributedString *result=[[NSMutableAttributedString alloc]init];
    UIFont *font;
    
    if(isBold){
        font=[UIFont boldSystemFontOfSize:size];
    }
    else{
        font=[UIFont systemFontOfSize:size];
    }
    
    NSDictionary *attributes=@{NSForegroundColorAttributeName:color,
                               NSFontAttributeName:font};
    NSScanner *scanner=[[NSScanner alloc]initWithString:string];
    scanner.charactersToBeSkipped=nil;
    NSString *tmp;
    NSRange range;
    range.location=0;
    range.length=0;
    while(![scanner isAtEnd]){
        if([scanner scanString:@"[color=#" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            UIColor *newColor=[CustomUtilities getColor:tmp];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/color]" intoString:&tmp];
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:newColor fontSize:size isBold:isBold withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
            [scanner scanString:@"[/color]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[size=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc] initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            CGFloat newSize=size;
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/size]" intoString:&tmp];
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:color fontSize:newSize isBold:isBold withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
            [scanner scanString:@"[/size]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[em" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            scanner.scanLocation-=2;
            [scanner scanUpToString:@"]" intoString:&tmp];
            [result appendAttributedString:[self getEmoji:tmp withFontSize:kContentFontSize]];
            [scanner scanString:@"]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[url=http://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=7;
            [scanner scanUpToString:@"]" intoString:&url];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/url]" intoString:&tmp];
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:tmp];
            content.font = [UIFont systemFontOfSize:size];
            content.color =[UIColor blueColor];
            
            YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
            highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            };
            [content setTextHighlight:highlight range:content.rangeOfAll];
            
            [result appendAttributedString:content];
            
            [scanner scanString:@"[/url]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[url=https://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=8;
            [scanner scanUpToString:@"]" intoString:&url];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/url]" intoString:&tmp];
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:tmp];
            content.font = [UIFont systemFontOfSize:size];
            content.color =[UIColor blueColor];
            
            YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
            highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            };
            [content setTextHighlight:highlight range:content.rangeOfAll];
            
            [result appendAttributedString:content];
            
            [scanner scanString:@"[/url]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"http://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=7;
            [scanner scanUpToString:@"\n" intoString:&url];
            
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:url];
            content.font = [UIFont systemFontOfSize:size];
            content.color =[UIColor blueColor];
            
            YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
            highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            };
            [content setTextHighlight:highlight range:content.rangeOfAll];
            
            [result appendAttributedString:content];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"https://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=8;
            [scanner scanUpToString:@"\n" intoString:&url];
            
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:url];
            content.font = [UIFont systemFontOfSize:size];
            content.color =[UIColor blueColor];
            
            YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
            highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            };
            [content setTextHighlight:highlight range:content.rangeOfAll];
            
            [result appendAttributedString:content];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[face=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/face]" intoString:&tmp];
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:color fontSize:size isBold:isBold withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
            [scanner scanString:@"[/face]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[b]" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"[/b]" intoString:&tmp];
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:color fontSize:size isBold:YES withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
            [scanner scanString:@"[/b]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
               else{
            scanner.scanLocation++;
            range.length++;
        }
    }
    
    [result appendAttributedString:[[NSAttributedString alloc] initWithString:[string substringWithRange:range] attributes:attributes]];
    return result;
}

#pragma mark - 获取一个信件对应的对应的attributedstring
-(NSMutableAttributedString*)
getAttributedStringWithArticle:(MailInfo*)mail
fontColor:(UIColor*)color
fontSize:(CGFloat)size
{
    NSMutableAttributedString*result=[self getAttributedStringByRecursiveWithString:mail.content fontColor:color fontSize:size isBold:NO withAttachmentInfo:nil withAttachmentUsedInfo:nil];
    
    return result;
}

@end
