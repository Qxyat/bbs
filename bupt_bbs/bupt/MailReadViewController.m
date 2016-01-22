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

#import <SVProgressHUD.h>
#import <YYKit.h>

#define kMargin 8
static CGFloat const kContentFontSize=15;

@interface MailReadViewController ()<HttpResponseDelegate>

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *useridLabel;
@property (weak, nonatomic) IBOutlet UILabel *posttimeLabel;
@property (weak, nonatomic) IBOutlet YYTextView *contentTextView;

@property (nonatomic) NSInteger index;
@property (copy,nonatomic) NSString* box_name;
@property (strong,nonatomic) MailInfo *maildata;

@end

@implementation MailReadViewController

+(instancetype)getInstanceWithMailBoxName:(NSString*)box_name
                                withIndex:(NSInteger)index{
    MailReadViewController *controller=[[MailReadViewController alloc]initWithNibName:@"MailReadControllerView" bundle:nil];
    controller.box_name=box_name;
    controller.index=index;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentTextView.editable=NO;
    
    [self.view addSubview:_faceImageView];
    [self.view addSubview:_titleLabel];
    
    [self _getMailData];
}

#pragma mark - 请求信件数据
- (void)_getMailData{
    [MailboxUtilities getMailWithMailbox:_box_name withIndex:_index withDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    _maildata=[MailInfo getMailInfo:response];
    [self _refreshView];
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
