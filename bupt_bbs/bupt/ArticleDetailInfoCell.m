//
//  ArticleDetailInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIImage+GIF.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <SDWebImageDownloader.h>
#import "ArticleDetailInfoCell.h"
#import "ShowUserInfoViewController.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"
#import "CaluateAttributedStringSizeUtilities.h"
#import "AttachmentInfo.h"
#import "AttachmentFile.h"
#import "DownloadResourcesUtilities.h"
#import "PictureInfo.h"
#import "LoginManager.h"
#import "YYImage+Emoji.h"
#import "ReplyViewController.h"
CGFloat const kMargin=4;
CGFloat const kMaxRatio=1.6;
CGFloat const kFaceImageViewHeight=30;
static CGFloat const kContentFontSize=15;

@interface ArticleDetailInfoCell()

@property (strong,nonatomic)ShowUserInfoViewController*showUserInfoViewController;
@property (strong,nonatomic)MWPhotoBrowser *photoBrowser;
@property (strong,nonatomic)NSMutableArray *photos;
@property (nonatomic)NSUInteger photo_pos;

@end

@implementation ArticleDetailInfoCell

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    UITapGestureRecognizer *tapGestureRecognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    self.faceImageView.userInteractionEnabled=YES;
    self.nameLabel.userInteractionEnabled=YES;
    [self.faceImageView addGestureRecognizer:tapGestureRecognizer1];
    [self.nameLabel addGestureRecognizer:tapGestureRecognizer2];
    UITapGestureRecognizer *tapGestureRecognizer3=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyArticle)];
    [self.replyImageView addGestureRecognizer:tapGestureRecognizer3];
    [self setSeparatorInset:UIEdgeInsetsMake(0, kMargin, 0, kMargin)];
}

#pragma mark -实现MWPhotoBrowserDelegate协议
-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return _photos.count;
}
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if(index<self.articleInfo.pictures.count){
        return _photos[index];
    }
    return nil;
}
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    if(index<self.articleInfo.pictures.count){
        return _photos[index];
    }
    return nil;
}
#pragma mark -
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)refreshCustomLayout{
    CGFloat imageviewHeight=kFaceImageViewHeight;
    CGFloat ratio=1;
    CGFloat imageviewWidth=kFaceImageViewHeight;
    
    if(self.faceImageView.image.size.height>0){
        ratio=self.faceImageView.image.size.width/self.faceImageView.image.size.height;
        if(ratio>kMaxRatio){
            ratio=kMaxRatio;
        }
    }
    imageviewWidth=imageviewHeight*ratio;
    
    self.faceImageView.frame=CGRectMake(kMargin, kMargin, imageviewWidth, imageviewHeight);
    self.labelContainer.frame=CGRectMake(2*kMargin+imageviewWidth, kMargin, kCustomScreenWidth-3*kMargin-imageviewWidth, kFaceImageViewHeight);
    self.nameLabel.frame=CGRectMake(0,0,self.labelContainer.frame.size.width*0.8, self.labelContainer.frame.size.height*0.5);
    self.floorLabel.frame=CGRectMake(self.labelContainer.frame.size.width*0.85, 0, 0.1*self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.timeLabel.frame=CGRectMake(0,self.labelContainer.frame.size.height*0.5,self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.contentLabel.frame=CGRectMake(kMargin,2*kMargin+kFaceImageViewHeight,  kCustomScreenWidth-2*kMargin, self.contentLabel.frame.size.height);
    self.replyImageView.frame=CGRectMake(kCustomScreenWidth-2*kMargin-kFaceImageViewHeight, 3*kMargin+kFaceImageViewHeight+self.contentLabel.frame.size.height, kFaceImageViewHeight, kFaceImageViewHeight);
    self.contentView.frame=CGRectMake(0,0,kCustomScreenWidth,4*kMargin+2*kFaceImageViewHeight+self.contentLabel.frame.size.height);
}
#pragma mark - 展示用户信息
-(void)showUserInfo{
    self.showUserInfoViewController=[ShowUserInfoViewController getInstance:self];
    self.showUserInfoViewController.userInfo=self.articleInfo.user;
    [self.showUserInfoViewController showUserInfoView];
}
#pragma mark - 实现ShowUserInfoViewControllerDelegate协议
-(void)userInfoViewControllerDidDismiss:(ShowUserInfoViewController *)userInfoViewController{
    if(self.showUserInfoViewController==userInfoViewController){
        [self.showUserInfoViewController hideUserInfoView];
        self.showUserInfoViewController=nil;
    }
}
#pragma mark - 填写cell内容
-(void)setArticleInfo:(ArticleInfo *)articleInfo{
    _articleInfo=articleInfo;
    _photo_pos=0;
    
    __weak typeof (self) _weakself=self;
    
    _photoBrowser=[[MWPhotoBrowser alloc]initWithDelegate:self];
    _photoBrowser.displayActionButton=NO;
   
    _photos=[[NSMutableArray alloc]initWithCapacity:_articleInfo.pictures.count];
    for(int i=0;i<_articleInfo.pictures.count;i++){
        PictureInfo *picture=_articleInfo.pictures[i];
        NSURL *url=nil;
        if(picture.isFromBBS){
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@?oauth_token=%@",picture.original_url,[LoginManager sharedManager].access_token]];
        }
        else{
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@",picture.original_url]];
        }

        [_photos addObject:[MWPhoto photoWithURL:url]];
    }

    YYImage *cachedFaceImage=[DownloadResourcesUtilities downloadImage:articleInfo.user.face_url FromBBS:YES Completed:^(YYImage *image) {
        _weakself.faceImageView.image=image;
        if(image.animatedImageType==YYImageTypeGIF)
            [_weakself.faceImageView startAnimating];
        [_weakself refreshCustomLayout];
    }];
    
    if(cachedFaceImage){
        self.faceImageView.image=cachedFaceImage;
        if(cachedFaceImage.animatedImageType==YYImageTypeGIF)
            [self.faceImageView startAnimating];
        [self refreshCustomLayout];
    }
    
    self.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    self.timeLabel.text=[CustomUtilities getPostTimeString:articleInfo.post_time];
    self.nameLabel.text=articleInfo.user.userId;
    
    CGSize boundSize=CGSizeMake(kCustomScreenWidth-2*kMargin, CGFLOAT_MAX);
    self.articleInfo.contentAttributesString=[self getAttributedStringWithArticle:self.articleInfo fontColor:[UIColor blackColor] fontSize:kContentFontSize];
    CGSize contentSize=sizeThatFitsAttributedString(self.articleInfo.contentAttributesString, boundSize, 0);
    self.articleInfo.contentSize=[NSValue valueWithCGSize:contentSize];
    
    self.contentLabel.attributedText=articleInfo.contentAttributesString;
    self.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=self.contentLabel.frame;
    contentLabelNewFrame.size=[articleInfo.contentSize CGSizeValue];
    self.contentLabel.frame=contentLabelNewFrame;
    
    [self refreshCustomLayout];
}


#pragma mark - 点击图片后相应的反馈
-(void)pictureTapped:(UIGestureRecognizer*)recognizer{
    YYAnimatedImageView *imageView=(YYAnimatedImageView*)recognizer.view;
    UITableViewController *controller=(UITableViewController*)self.delegate;
    [_photoBrowser setCurrentPhotoIndex:imageView.tag];
    [controller.navigationController pushViewController:_photoBrowser animated:YES];
}

#pragma mark - 打开回复文章的标题
-(void)replyArticle{
    UITableViewController *controller=(UITableViewController*)self.delegate;
    [controller.navigationController pushViewController:[ReplyViewController getInstanceWithBoardName:self.articleInfo.board_name isNewTheme:NO withArticleName:self.articleInfo.title withArticleId:self.articleInfo.articleId withArticleInfo:self.articleInfo ] animated:YES];
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

#pragma mark - 根据图片在附件中的位置获得对应的Attributed String
-(NSAttributedString*)
getImageInAttachment:(AttachmentInfo*)attachmentInfo
withPosition:(NSUInteger)pos
withAttachmentUsedInfo:(NSMutableArray *)used{
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]init];
    __weak typeof(self) _weakself=self;
    if(used!=nil&&pos<=attachmentInfo.file.count){
        AttachmentFile *file=attachmentInfo.file[pos-1];
        if(used[pos-1]==[NSNumber numberWithBool:NO]&&[CustomUtilities isPicture:file.name]){
            used[pos-1]=[NSNumber numberWithInt:YES];
            
            YYImage *cachedImage=[DownloadResourcesUtilities downloadImage:file.url FromBBS:YES Completed:^(YYImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_weakself.delegate refreshTableView:file.url];
                });
            }];
            
            if(cachedImage){
                CGFloat width=cachedImage.size.width;
                CGFloat height=cachedImage.size.height;
                if(width>kCustomScreenWidth-2*kMargin){
                    height=(height/width)*(kCustomScreenWidth-2*kMargin);
                    width=kCustomScreenWidth-2*kMargin;
                    
                }
                height+=10;//图片之间的间隔
                YYAnimatedImageView *imageView=[[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
                imageView.contentMode=UIViewContentModeScaleAspectFit;
                imageView.tag=_photo_pos;
                _photo_pos++;
                imageView.image=cachedImage;
                imageView.userInteractionEnabled=YES;
                UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pictureTapped:)];
                [imageView addGestureRecognizer:tapGestureRecognizer];
                //使用YYKit提供的方法，后期争取能替换成自己的
                NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(kCustomScreenWidth-2*kMargin, height)  alignToFont:[UIFont systemFontOfSize:kContentFontSize] alignment:YYTextVerticalAlignmentCenter];
                [res appendAttributedString:attachText];
            }
        }
    }
    
    return res;
}
#pragma mark - 从非附件中下载图片
-(NSAttributedString *)getImageFromString:(NSString*)string{
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]init];
    __weak typeof(self) _weakself=self;
    
    YYImage *cachedImage=[DownloadResourcesUtilities downloadImage:string FromBBS:NO Completed:^(YYImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_weakself.delegate refreshTableView:string];
        });
    }];
    
    if(cachedImage){
        CGFloat width=cachedImage.size.width;
        CGFloat height=cachedImage.size.height;
        if(width>kCustomScreenWidth-2*kMargin){
            height=(height/width)*(kCustomScreenWidth-2*kMargin);
            width=kCustomScreenWidth-2*kMargin;
            
        }
        height+=10;//图片之间的间隔
        YYAnimatedImageView *imageView=[[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.tag=_photo_pos;
        _photo_pos++;
        imageView.image=cachedImage;
        imageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pictureTapped:)];
        [imageView addGestureRecognizer:tapGestureRecognizer];
        //使用YYKit提供的方法，后期争取能替换成自己的
        NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(kCustomScreenWidth-2*kMargin, height)  alignToFont:[UIFont systemFontOfSize:kContentFontSize] alignment:YYTextVerticalAlignmentCenter];
        [res appendAttributedString:attachText];
    }
 
    return res;
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
        else if([scanner scanString:@"[upload=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            int pos=1;
            [scanner scanInt:&pos];
            [result appendAttributedString:[self getImageInAttachment:attachmentInfo withPosition:pos withAttachmentUsedInfo:used]];
            [scanner scanString:@"][/upload]" intoString:nil];
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
        else if([scanner scanString:@"[img=http://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=7;
            [scanner scanUpToString:@"]" intoString:&url];
            
            [result appendAttributedString:[self getImageFromString:url]];
            
            [scanner scanString:@"][/img]" intoString:nil];

            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[img=https://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=8;
            [scanner scanUpToString:@"]" intoString:&url];
            
            [result appendAttributedString:[self getImageFromString:url]];
            
            [scanner scanString:@"][/img]" intoString:nil];
            
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

#pragma mark - 获取一篇文章内容对应的对应的attributedstring
-(NSMutableAttributedString*)
getAttributedStringWithArticle:(ArticleInfo*)article
fontColor:(UIColor*)color
fontSize:(CGFloat)size
{
    NSMutableArray *used=nil;
    AttachmentInfo *attachmentInfo=article.attachment;
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
        used=[[NSMutableArray alloc] initWithCapacity:attachmentInfo.file.count];
        for(int i=0;i<attachmentInfo.file.count;i++){
            [used addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    NSMutableAttributedString*result=[self getAttributedStringByRecursiveWithString:article.content fontColor:color fontSize:size isBold:NO withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used];
    
    if(used!=nil){
        for(int i=1;i<=attachmentInfo.file.count;i++){
            [result appendAttributedString:[self getImageInAttachment:attachmentInfo withPosition:i withAttachmentUsedInfo:used]];
        }
        
    }
    return result;
}
@end
