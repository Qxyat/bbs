//
//  AttributedStringUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/9.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "AttributedStringUtilities.h"
#import <UIImageView+WebCache.h>
#import <YYKit.h>
#import "ArticleInfo.h"
#import "AttachmentInfo.h"
#import "AttachmentFile.h"
#import "LoginConfiguration.h"
#import "CaluateAttributedStringSizeUtilities.h"

#pragma mark - 根据颜色代码获得颜色
static UIColor* getColor(NSString * hexColor)
{
    NSUInteger red,green,blue;
    NSRange range;
    
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

#pragma mark - 根据表情代码获取表情对应的Attributed String
static NSAttributedString* getEmoji(NSString*string,CGFloat fontSize)
{
    UIFont* font=[UIFont systemFontOfSize:fontSize];
    CGFloat imageWidth=font.ascender-font.descender+10;
    NSRange range =[string rangeOfString:@"^[a-zA-z]+" options:NSRegularExpressionSearch];
    NSString* url=[NSString stringWithFormat:@"%@/%@/%@.gif",@"http://bbs.byr.cn/img/ubb",[string substringWithRange:range],[string substringFromIndex:range.location+range.length]];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    //使用YYKit提供的方法，后期争取能替换成自己的
    NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    
    return attachText;
}

#pragma mark - 判断一个字符串对应的url是否是图片
bool isPicture(NSString *string){
    NSArray* array=[string componentsSeparatedByString:@"."];
    if([array count]>1){
        return [array[1] isEqualToString:@"png"]||
        [array[1] isEqualToString:@"jpg"]||
        [array[1] isEqualToString:@"jpeg"]||
        [array[1] isEqualToString:@"gif"];
    }
    return NO;
}

#pragma mark - 根据图片在附件中的位置获得对应的Attributed String
static NSAttributedString* getPictureInAttachment(AttachmentInfo*attachmentInfo,NSUInteger pos,NSMutableArray * used){
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]init];
    if(used!=nil&&pos<=attachmentInfo.file.count){
        AttachmentFile *file=attachmentInfo.file[pos-1];
        if(used[pos-1]==[NSNumber numberWithBool:NO]&&isPicture(file.name)){
            used[pos-1]=[NSNumber numberWithInt:YES];
            
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 450)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:
                                           [NSString stringWithFormat:@"%@?oauth_token=%@",file.thumbnail_middle,[LoginConfiguration getInstance].access_token]]];
            //使用YYKit提供的方法，后期争取能替换成自己的
            NSMutableAttributedString* attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont systemFontOfSize:17] alignment:YYTextVerticalAlignmentCenter];
            [res appendAttributedString:attachText];
            [res appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n\n"]];
        }
    }
    
    return res;
}

#pragma mark -
@implementation AttributedStringUtilities

#pragma mark - 后台获取一页文章的AttributedStirng和Size组成的数组
+(void)getAttributedStringsWithArray:(NSArray *)array
                         StringColor:(UIColor *)color
                          StringSize:(CGFloat)fontSize
                           BoundSize:(CGSize)boundSize
                            Delegate:(id<AttributedStringDelegate>)delegate{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *res=[[NSMutableArray alloc]initWithCapacity:array.count];
        for(int i=0;i<array.count;i++){
            ArticleInfo *articleInfo=(ArticleInfo*)array[i];
            NSAttributedString *attributedString=[AttributedStringUtilities getAttributedStringWithString:articleInfo.content StringColor:color StringSize:fontSize Attachments:articleInfo.attachment];
            CGSize size=sizeThatFitsAttributedString(attributedString, boundSize, 0);
            
            [res addObject:@{@"AttributedString":attributedString,
                             @"Size":NSStringFromCGSize(size)}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate handleAttribuedStringResponse:res];
        });
    });
}

#pragma mark - 获取一篇文章的string对应的attributedstring
+(NSMutableAttributedString*)
            getAttributedStringWithString:(NSString*)string
                              StringColor:(UIColor*)color
                               StringSize:(CGFloat)size
                              Attachments:(AttachmentInfo*)attachmentInfo
{
    NSMutableArray *used=nil;
    if(attachmentInfo!=nil&&attachmentInfo.file!=nil){
        used=[[NSMutableArray alloc] initWithCapacity:attachmentInfo.file.count];
        for(int i=0;i<attachmentInfo.file.count;i++){
            [used addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    NSMutableAttributedString*result=[AttributedStringUtilities getAttributedStringByRecursiveWithString:string StringColor:color StringSize:size Attachments:attachmentInfo AttachmentsUsed:used];
    
    if(used!=nil){
        for(int i=1;i<=attachmentInfo.file.count;i++){
            [result appendAttributedString:getPictureInAttachment(attachmentInfo, i, used)];
        }
        
    }
    return result;
}

#pragma mark - 通过递归的方式获取对应的attributedstring
+(NSMutableAttributedString*)
getAttributedStringByRecursiveWithString:(NSString*)string
                             StringColor:(UIColor*)color
                              StringSize:(CGFloat)size
                             Attachments:(AttachmentInfo*)attachmentInfo
                         AttachmentsUsed:(NSMutableArray*)used
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
            UIColor *newColor=getColor(tmp);
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/color]" intoString:&tmp];
            [result appendAttributedString:[AttributedStringUtilities getAttributedStringByRecursiveWithString:tmp StringColor:newColor StringSize:size Attachments:attachmentInfo AttachmentsUsed:used]];
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
            [result appendAttributedString:[AttributedStringUtilities getAttributedStringByRecursiveWithString:tmp StringColor:color StringSize:newSize Attachments:attachmentInfo AttachmentsUsed:used]];
            [scanner scanString:@"[/size]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[em" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            scanner.scanLocation-=2;
            [scanner scanUpToString:@"]" intoString:&tmp];
            [result appendAttributedString:getEmoji(tmp,size)];
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
            [result appendAttributedString:[AttributedStringUtilities getAttributedStringByRecursiveWithString:tmp StringColor:color StringSize:size Attachments:attachmentInfo AttachmentsUsed:used]];
            [scanner scanString:@"[/url]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[upload=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            int pos=1;
            [scanner scanInt:&pos];
            [result appendAttributedString:getPictureInAttachment( attachmentInfo,pos,used)];
            [scanner scanString:@"][/upload]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:@"[face=" intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/face]" intoString:&tmp];
            [result appendAttributedString:[AttributedStringUtilities getAttributedStringByRecursiveWithString:tmp StringColor:color StringSize:size Attachments:attachmentInfo AttachmentsUsed:used]];
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
@end
