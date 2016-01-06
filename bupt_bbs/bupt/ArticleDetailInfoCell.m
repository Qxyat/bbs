//
//  ArticleDetailInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <SDWebImageDownloader.h>
#import <YYKit.h>
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

-(void)layoutSubviews{
    [super layoutSubviews];
    [self refreshCustomLayout];
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
    self.replyImageView.frame=CGRectMake(kCustomScreenWidth-kMargin-kFaceImageViewHeight, kMargin, kFaceImageViewHeight, kFaceImageViewHeight);
    self.labelContainer.frame=CGRectMake(2*kMargin+imageviewWidth, kMargin, kCustomScreenWidth-4*kMargin-imageviewWidth-kFaceImageViewHeight, kFaceImageViewHeight);
    self.floorLabel.frame=CGRectMake(0, 0, 0.25*self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.timeLabel.frame=CGRectMake(self.floorLabel.frame.size.width, 0, 0.75*self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.nameLabel.frame=CGRectMake(0,self.labelContainer.frame.size.height*0.5,self.labelContainer.frame.size.width, self.labelContainer.frame.size.height*0.5);
    self.contentLabel.frame=CGRectMake(kMargin,2*kMargin+kFaceImageViewHeight,  kCustomScreenWidth-2*kMargin, self.contentLabel.frame.size.height);
    self.contentView.frame=CGRectMake(0,0,kCustomScreenWidth,3*kMargin+kFaceImageViewHeight+self.contentLabel.frame.size.height);
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
    
    __weak typeof (self) target=self;
    
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
    
    [self.faceImageView sd_setImageWithURL:[NSURL URLWithString:articleInfo.user.face_url] placeholderImage:[UIImage imageNamed:@"face_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [target refreshCustomLayout];
    }];
    self.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    self.timeLabel.text=[CustomUtilities getPostTimeString:articleInfo.post_time];
    self.nameLabel.text=articleInfo.user.userId;
    
    CGSize boundSize=CGSizeMake(kCustomScreenWidth-2*kMargin, 10000);
    self.articleInfo.contentAttributesString=[self getAttributedStringWithArticle:self.articleInfo fontColor:[UIColor blackColor] fontSize:kContentFontSize];
    CGSize contentSize=sizeThatFitsAttributedString(self.articleInfo.contentAttributesString, boundSize, 0);
    self.articleInfo.contentSize=[NSValue valueWithCGSize:contentSize];
    
    self.contentLabel.attributedText=articleInfo.contentAttributesString;
    self.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=self.contentLabel.frame;
    contentLabelNewFrame.size=[articleInfo.contentSize CGSizeValue];
    self.contentLabel.frame=contentLabelNewFrame;
}
#pragma mark - 根据表情代码获取表情对应的Attributed String
-(NSAttributedString*)getEmoji:(NSString*)string
                  withFontSize:(CGFloat)fontSize
{
    UIFont* font=[UIFont systemFontOfSize:fontSize];
    CGFloat imageWidth=font.ascender-font.descender+10;
    NSRange range =[string rangeOfString:@"^[a-zA-z]+" options:NSRegularExpressionSearch];
    NSString* url=[NSString stringWithFormat:@"%@/%@/%@.gif",@"http://bbs.byr.cn/img/ubb",[string substringWithRange:range],[string substringFromIndex:range.location+range.length]];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
    UIImage *cachedImage=[[SDImageCache sharedImageCache]imageFromDiskCacheForKey:url];
    if(cachedImage){
        imageView.image=cachedImage;
    }
    else
        [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    //使用YYKit提供的方法，后期争取能替换成自己的
    NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    
    return attachText;
}

#pragma mark - 根据图片在附件中的位置获得对应的Attributed String
-(NSAttributedString*)
    getPictureInAttachment:(AttachmentInfo*)attachmentInfo
              withPosition:(NSUInteger)pos
    withAttachmentUsedInfo:(NSMutableArray *)used{
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]init];
    __weak typeof(self) target=self;
    if(used!=nil&&pos<=attachmentInfo.file.count){
        AttachmentFile *file=attachmentInfo.file[pos-1];
        if(used[pos-1]==[NSNumber numberWithBool:NO]&&[CustomUtilities isPicture:file.name]){
            used[pos-1]=[NSNumber numberWithInt:YES];
            
            UIImage *cachedImage=[[SDImageCache sharedImageCache]imageFromDiskCacheForKey:file.thumbnail_middle];
            if(cachedImage){
                CGFloat width=cachedImage.size.width;
                CGFloat height=cachedImage.size.height;
                if(width>kCustomScreenWidth-2*kMargin){
                    width=kCustomScreenWidth-2*kMargin;
                    height=(height/width)*(kCustomScreenWidth-2*kMargin);
                }
                UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
                imageView.tag=_photo_pos;
                _photo_pos++;
                imageView.image=cachedImage;
                imageView.userInteractionEnabled=YES;
                UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pictureTapped:)];
                [imageView addGestureRecognizer:tapGestureRecognizer];
                //使用YYKit提供的方法，后期争取能替换成自己的
                NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(kCustomScreenWidth-2*kMargin, height)  alignToFont:[UIFont systemFontOfSize:kContentFontSize] alignment:YYTextVerticalAlignmentCenter];
                [res appendAttributedString:attachText];
                [res appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n\n"]];
            }
            else{
                [DownloadResourcesUtilities downloadPicture:file.thumbnail_middle FromBBS:YES Completed:^{
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [target.delegate refreshTableView:file.thumbnail_middle];
                      });
                }];
            }
            
        }
    }
    
    return res;
}

#pragma mark - 通过递归的方式获取对应的attributedstring
-(NSMutableAttributedString*)
getAttributedStringByRecursiveWithString:(NSString*)string
                               fontColor:(UIColor*)color
                                fontSize:(CGFloat) size
                      withAttachmentInfo:(AttachmentInfo*)
                                          attachmentInfo
                  withAttachmentUsedInfo:(NSMutableArray*)used
{
    NSMutableAttributedString *result=[[NSMutableAttributedString alloc]init];
    NSDictionary *attributes=@{NSForegroundColorAttributeName:color,
                               NSFontAttributeName:[UIFont systemFontOfSize:size]};
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
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:newColor fontSize:size withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
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
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:color fontSize:newSize withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
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
            scanner.scanLocation-=7;
            [scanner scanUpToString:@"]" intoString:&tmp];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/url]" intoString:&tmp];
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:color fontSize:size withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
            [scanner scanString:@"[/url]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[upload=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            int pos=1;
            [scanner scanInt:&pos];
            [result appendAttributedString:[self getPictureInAttachment:attachmentInfo withPosition:pos withAttachmentUsedInfo:used]];
            [scanner scanString:@"][/upload]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[face=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/face]" intoString:&tmp];
            [result appendAttributedString:[self getAttributedStringByRecursiveWithString:tmp fontColor:color fontSize:size withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used]];
            [scanner scanString:@"[/face]" intoString:nil];
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
    
    NSMutableAttributedString*result=[self getAttributedStringByRecursiveWithString:article.content fontColor:color fontSize:size withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used];
    
    if(used!=nil){
        for(int i=1;i<=attachmentInfo.file.count;i++){
            [result appendAttributedString:[self getPictureInAttachment:attachmentInfo withPosition:i withAttachmentUsedInfo:used]];
        }
        
    }
    return result;
}

#pragma mark - 点击图片后相应的反馈
-(void)pictureTapped:(UIGestureRecognizer*)recognizer{
    UIImageView *imageView=(UIImageView*)recognizer.view;
    UITableViewController *controller=(UITableViewController*)self.delegate;
    [_photoBrowser setCurrentPhotoIndex:imageView.tag];
    [controller.navigationController pushViewController:_photoBrowser animated:YES];
}
@end
