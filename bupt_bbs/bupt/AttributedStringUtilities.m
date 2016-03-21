 //
//  CaluateAttributedStringSizeUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/14.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "AttributedStringUtilities.h"
#import "YYImage+Emoji.h"
#import "AttachmentFile.h"
#import "AttachmentInfo.h"
#import "CustomUtilities.h"
#import "DownloadResourcesUtilities.h"
#import "ScreenAdaptionUtilities.h"
#import "ArticleInfo.h"
#import "PictureInfo.h"
#import "CustomYYAnimatedImageView.h"

#import <YYKit.h>
#import <CoreText/CoreText.h>

#pragma mark - 获得AttributedString高度的相关方法
static CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static CGFloat const TTTFLOAT_MAX = 100000;

static CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, TTTFLOAT_MAX);
    
    if (numberOfLines == 1) {
        // If there is one line, the size that fits is the full width of the line
        constraints = CGSizeMake(TTTFLOAT_MAX, TTTFLOAT_MAX);
    } else if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, TTTFLOAT_MAX));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CGPathRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
}

CGSize sizeThatFitsAttributedString(NSAttributedString *attributedString,
                                    CGSize size,NSUInteger numberOfLines)
{
    if (!attributedString || attributedString.length == 0) {
        return CGSizeZero;
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    
    CGSize calculatedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, attributedString, size, numberOfLines);
    
    CFRelease(framesetter);
    
    return calculatedSize;
}

@implementation AttributedStringUtilities
{
    NSUInteger _photo_pos;
    CGFloat _fontSize;
}
#pragma mark - 根据表情代码获得表情对应的AttributedString

-(id)init{
    if(self=[super init]){
        _photo_pos=0;
    }
    return self;
}
-(NSAttributedString*)
getEmojiAttributedStringWithString:(NSString*)string
                          fontSize:(CGFloat)fontSize
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
            position:(NSUInteger)pos
  attachmentUsedInfo:(NSMutableArray *)used{
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]init];
    
    if(used!=nil&&pos<=attachmentInfo.file.count){
        AttachmentFile *file=attachmentInfo.file[pos-1];
        if(used[pos-1]==[NSNumber numberWithBool:NO]&&[CustomUtilities isPicture:file.name]){
            used[pos-1]=[NSNumber numberWithInt:YES];
            UIImage *cachedImage;
            if(!_delegate.isPictureArrayAlready){
                PictureInfo *picture=[[PictureInfo alloc]init];
                picture.thumbnail_url=file.thumbnail_middle;
                picture.original_url=file.url;
                picture.isFromBBS=YES;
                picture.isDownloading=NO;
                picture.isDownloaded=NO;
                picture.isFailed=NO;
                picture.isShowed=NO;
                [_delegate.pictures addObject:picture];
            }
        
            PictureInfo *curPictureInfo=_delegate.pictures[_photo_pos];
            @synchronized(curPictureInfo) {
                if(curPictureInfo.isDownloading==NO&&curPictureInfo.isDownloaded==NO){
                    curPictureInfo.isDownloading=YES;
                    cachedImage=[DownloadResourcesUtilities downloadImage:file.url FromBBS:YES Completed:^(YYImage *image,BOOL isFailed) {
                        @synchronized(curPictureInfo) {
                            curPictureInfo.isDownloading=NO;
                            curPictureInfo.isFailed=isFailed;
                            curPictureInfo.isDownloaded=YES;
                            curPictureInfo.isShowed=NO;
                            curPictureInfo.image=image;
                            [_delegate updateAttributedString];
                        }
                    }];
                    if(cachedImage){
                        curPictureInfo.isDownloading=NO;
                        curPictureInfo.isDownloaded=YES;
                        curPictureInfo.isShowed=YES;
                        curPictureInfo.isFailed=NO;
                        curPictureInfo.image=cachedImage;
                    }
                    else{
                        curPictureInfo.isDownloaded=NO;
                        curPictureInfo.isShowed=NO;
                        curPictureInfo.isFailed=NO;
                        cachedImage=[UIImage imageNamed:@"picIsdownloading"];
                    }
                }
                else if(curPictureInfo.isDownloaded){
                    curPictureInfo.isDownloading=NO;
                    if(curPictureInfo.isFailed){
                        cachedImage=[UIImage imageNamed:@"picdownloadfailed"];
                    }
                    else{
                        cachedImage=curPictureInfo.image;
                        curPictureInfo.isShowed=YES;
                    }
                }
            }
            
            CGFloat width=cachedImage.size.width;
            CGFloat height=cachedImage.size.height;
            if(width>kCustomScreenWidth-2*kMargin){
                height=(height/width)*(kCustomScreenWidth-2*kMargin);
                width=kCustomScreenWidth-2*kMargin;
                
            }
            height+=10;//图片之间的间隔
            CustomYYAnimatedImageView *imageView=[[CustomYYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            imageView.tag=_photo_pos;
            imageView.opaque=YES;
            imageView.image=cachedImage;
            imageView.userInteractionEnabled=YES;
            imageView.isFailed=curPictureInfo.isFailed;
            UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:_delegate action:@selector(pictureTapped:)];
            [imageView addGestureRecognizer:tapGestureRecognizer];
            //使用YYKit提供的方法，后期争取能替换成自己的
            NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(kCustomScreenWidth-2*kMargin, height)  alignToFont:[UIFont systemFontOfSize:_fontSize] alignment:YYTextVerticalAlignmentCenter];
            [res appendAttributedString:attachText];
             _photo_pos++;
        }
    }
    return res;
}
#pragma mark - 从非附件中下载图片
-(NSAttributedString *)getImageFromURL:(NSString*)string{
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]init];
    
    UIImage *cachedImage;
    if(!_delegate.isPictureArrayAlready){
        PictureInfo *picture=[[PictureInfo alloc]init];
        picture.thumbnail_url=string;
        picture.original_url=string;
        picture.isFromBBS=NO;
        picture.isDownloading=NO;
        picture.isDownloaded=NO;
        picture.isFailed=NO;
        picture.isShowed=NO;
        [_delegate.pictures addObject:picture];
    }
    
    PictureInfo *curPictureInfo=_delegate.pictures[_photo_pos];
    @synchronized(curPictureInfo) {
        if(curPictureInfo.isDownloading==NO&&curPictureInfo.isDownloaded==NO){
            curPictureInfo.isDownloading=YES;
            cachedImage=[DownloadResourcesUtilities downloadImage:string FromBBS:NO Completed:^(YYImage *image,BOOL isFailed) {
                @synchronized(curPictureInfo) {
                    curPictureInfo.isDownloading=NO;
                    curPictureInfo.isFailed=isFailed;
                    curPictureInfo.isDownloaded=YES;
                    curPictureInfo.isShowed=NO;
                    curPictureInfo.image=image;

                    [_delegate updateAttributedString];
                }
            }];
            if(cachedImage){
                curPictureInfo.isDownloading=NO;
                curPictureInfo.isDownloaded=YES;
                curPictureInfo.isShowed=YES;
                curPictureInfo.isFailed=NO;
                curPictureInfo.image=cachedImage;
            }
            else{
                curPictureInfo.isDownloaded=NO;
                curPictureInfo.isShowed=NO;
                curPictureInfo.isFailed=NO;
                cachedImage=[UIImage imageNamed:@"picIsdownloading"];
            }
        }
        else if(curPictureInfo.isDownloaded){
            curPictureInfo.isDownloading=NO;
            if(curPictureInfo.isFailed){
                cachedImage=[UIImage imageNamed:@"picdownloadfailed"];
            }
            else{
                cachedImage=curPictureInfo.image;
                curPictureInfo.isShowed=YES;
            }
        }
    }
    
    CGFloat width=cachedImage.size.width;
    CGFloat height=cachedImage.size.height;
    if(width>kCustomScreenWidth-2*kMargin){
        height=(height/width)*(kCustomScreenWidth-2*kMargin);
        width=kCustomScreenWidth-2*kMargin;
        
    }
    height+=10;//图片之间的间隔
    CustomYYAnimatedImageView *imageView=[[CustomYYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.tag=_photo_pos;
    imageView.opaque=YES;
    imageView.image=cachedImage;
    imageView.userInteractionEnabled=YES;
    imageView.isFailed=curPictureInfo.isFailed;
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:_delegate action:@selector(pictureTapped:)];
    [imageView addGestureRecognizer:tapGestureRecognizer];
    //使用YYKit提供的方法，后期争取能替换成自己的
    NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(kCustomScreenWidth-2*kMargin, height)  alignToFont:[UIFont systemFontOfSize:_fontSize] alignment:YYTextVerticalAlignmentCenter];
    [res appendAttributedString:attachText];
    _photo_pos++;
    
    return res;
}
#pragma mark - 通过递归的方式获取对应的attributedstring
-(NSMutableAttributedString*)
getAttributedStringByRecursiveWithString:(NSString*)string
                               fontColor:(UIColor*)color
                                fontSize:(CGFloat) size
                                  isBold:(BOOL)isBold
                withAttachmentInfo:(AttachmentInfo*)attachmentInfo
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
            [result appendAttributedString:[self getEmojiAttributedStringWithString:tmp fontSize:_fontSize]];
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
            [result appendAttributedString:[self getImageInAttachment:attachmentInfo position:pos attachmentUsedInfo:used]];
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
            
            [result appendAttributedString:[self getImageFromURL:url]];
            
            [scanner scanString:@"][/img]" intoString:nil];
            
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[img=https://" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            NSString *url;
            scanner.scanLocation-=8;
            [scanner scanUpToString:@"]" intoString:&url];
            
            [result appendAttributedString:[self getImageFromURL:url]];
            
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
    
    _photo_pos=0;
    _fontSize=size;
    
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
        used=[[NSMutableArray alloc] initWithCapacity:attachmentInfo.file.count];
        for(int i=0;i<attachmentInfo.file.count;i++){
            [used addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    NSMutableAttributedString*result=[self getAttributedStringByRecursiveWithString:article.content fontColor:color fontSize:size isBold:NO withAttachmentInfo:attachmentInfo withAttachmentUsedInfo:used];
    
    if(used!=nil){
        for(int i=1;i<=attachmentInfo.file.count;i++){
            [result appendAttributedString:[self getImageInAttachment:attachmentInfo position:i attachmentUsedInfo:used]];
        }
        
    }
    _delegate.isPictureArrayAlready=YES;
    return result;
}
@end