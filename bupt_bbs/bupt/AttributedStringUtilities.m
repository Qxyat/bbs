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
static NSString *const kColorBeginTag=@"[color=#";
static NSString *const kSizeBeginTag=@"[size=";
static NSString *const kEmojiBeginTag=@"[em";

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
#pragma mark - 根据表情代码获取表情
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

#pragma mark -
@implementation AttributedStringUtilities

#pragma mark - 后台获取一页的AttributedStirng和Size组成的数组
+(void)getAttributedStringsWithArray:(NSArray *)array
                         StringColor:(UIColor *)color
                          StringSize:(CGFloat)fontSize
                           BoundSize:(CGSize)boundSize
                            Delegate:(id<AttributedStringDelegate>)delegate{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *res=[[NSMutableArray alloc]initWithCapacity:array.count];
        for(int i=0;i<array.count;i++){
            NSAttributedString *attributedString=[AttributedStringUtilities getAttributedStringWithString:[(ArticleInfo*)array[i] content] StringColor:color StringSize:fontSize];
            CGSize size=sizeThatFitsAttributedString(attributedString, boundSize, 0);
            [res addObject:@{@"AttributedString":attributedString,
                               @"Size":NSStringFromCGSize(size)}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate handleAttribuedStringResponse:res];
        });
    });
}
#pragma mark - 获取string对应的attributedstring
+(NSMutableAttributedString*)getAttributedStringWithString:(NSString*)                     string
                                              StringColor:(UIColor*)color
                                               StringSize:(CGFloat)size

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
        if([scanner scanString:kColorBeginTag intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            UIColor *newColor=getColor(tmp);
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/color]" intoString:&tmp];
            [result appendAttributedString:[AttributedStringUtilities getAttributedStringWithString:tmp StringColor:newColor StringSize:size]];
            [scanner scanString:@"[/color]" intoString:nil];
            range.location=scanner.scanLocation;
            range.length=0;
        }
        else if([scanner scanString:kSizeBeginTag intoString:nil]){
            [result appendAttributedString:[[NSAttributedString alloc] initWithString:[string substringWithRange:range] attributes:attributes]];
            [scanner scanUpToString:@"]" intoString:&tmp];
            CGFloat newSize=size;
            [scanner scanString:@"]" intoString:nil];
            [scanner scanUpToString:@"[/size]" intoString:&tmp];
            [result appendAttributedString:[AttributedStringUtilities getAttributedStringWithString:tmp StringColor:color StringSize:newSize]];
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
            [result appendAttributedString:[[NSAttributedString alloc]initWithString:tmp attributes:attributes]];
            [scanner scanString:@"[/url]" intoString:nil];
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
