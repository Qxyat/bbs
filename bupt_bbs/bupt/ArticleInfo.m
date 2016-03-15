//
//  Article.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/2.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ArticleInfo.h"
#import "UserInfo.h"
#import "AttachmentInfo.h"
#import "AttributedStringUtilities.h"
#import "DownloadResourcesUtilities.h"
#import "ScreenAdaptionUtilities.h"
#import "PictureInfo.h"
#import "CustomYYAnimatedImageView.h"

static NSString* const kArticleId=@"id";
static NSString* const kGroupId=@"group_id";
static NSString* const kReplyId=@"reply_id";
static NSString* const kFlag=@"flag";
static NSString* const kPosition=@"position";
static NSString* const kIsTop=@"is_top";
static NSString* const kIsSubject=@"is_subject";
static NSString* const kHasAttachment=@"has_attachment";
static NSString* const kIsAdmin=@"is_admin";
static NSString* const kTitle=@"title";
static NSString* const kUser=@"user";
static NSString* const kPostTime=@"post_time";
static NSString* const kBoardName=@"board_name";
static NSString* const kContent=@"content";
static NSString* const kAttachment=@"attachment";
static NSString* const kPreviousId=@"previous_id";
static NSString* const kNextId=@"next_id";
static NSString* const kThreadPreviousId=@"threads_previous_id";
static NSString* const kThreadNextId=@"threads_next_id";
static NSString* const kReplyCount=@"reply_count";
static NSString* const kLastReplyUserId=@"last_reply_user_id";
static NSString* const kLastReplyTime=@"last_reply_time";

static CGFloat const kContentFontSize=15;

CGSize getStringSize(NSString *string){
    CGSize maxSize=CGSizeMake(kCustomScreenWidth-2*kMargin, CGFLOAT_MAX);
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *dic=@{NSFontAttributeName:[UIFont systemFontOfSize:kContentFontSize]};
    return [string boundingRectWithSize:maxSize options:options attributes:dic context:nil].size;
}

@interface ArticleInfo ()<AttributedStringUtilitiesDelegate>

@property (strong)AttributedStringUtilities *attributedUtilities;

@end


@implementation ArticleInfo
#pragma mark - 得到一页当中所有的文章的信息
+(NSMutableArray*)getArticlesInfo:(id)item{
    NSMutableArray *mutableArray=nil;
    if(item!=[NSNull null]){
        NSArray *array=(NSArray*)item;
        mutableArray=[[NSMutableArray alloc]initWithCapacity:array.count];
        for(int i=0;i<array.count;i++){
            [mutableArray addObject:[ArticleInfo getArticleInfo:array[i]]];
        }
    }
    return mutableArray;
}
#pragma mark - 得到一篇文章的信息
+(ArticleInfo *)getArticleInfo:(id)item{
    ArticleInfo *articleInfo=[[ArticleInfo alloc]init];
    NSDictionary *dic=(NSDictionary*)item;
    
    articleInfo.articleId=[[dic objectForKey:kArticleId] intValue];
    articleInfo.group_id=[[dic objectForKey:kGroupId] intValue];
    articleInfo.reply_id=[[dic objectForKey:kReplyId] intValue];
    articleInfo.flag=[dic objectForKey:kFlag];
    articleInfo.position=[[dic objectForKey:kPosition] intValue];
    articleInfo.is_top=[[dic objectForKey:kIsTop] boolValue];
    articleInfo.is_subject=[[dic objectForKey:kIsSubject] boolValue];
    articleInfo.has_attachment=[[dic objectForKey:kHasAttachment] boolValue];
    articleInfo.is_admin=[[dic objectForKey:kIsAdmin] boolValue];
    articleInfo.title=[dic objectForKey:kTitle];
    articleInfo.user=[UserInfo getUserInfo:[dic objectForKey:kUser]];
    articleInfo.post_time=[[dic objectForKey:kPostTime] intValue];
    articleInfo.board_name=[dic objectForKey:kBoardName];
    articleInfo.content=[dic objectForKey:kContent];
    articleInfo.attachment=[AttachmentInfo getAttachmentInfo:[dic objectForKey:kAttachment]];
    articleInfo.previous_id=[[dic objectForKey:kPreviousId]intValue];
    articleInfo.next_id=[[dic objectForKey:kNextId] intValue];
    articleInfo.threads_previous_id=[[dic objectForKey:kThreadPreviousId] intValue];
    articleInfo.threads_next_id=[[dic objectForKey:kThreadNextId] intValue];
    articleInfo.reply_count=[[dic objectForKey:kReplyCount] intValue];
    articleInfo.last_reply_user_id=[dic objectForKey:kLastReplyUserId];
    articleInfo.last_reply_time=[[dic objectForKey:kLastReplyTime] intValue];
    articleInfo.isPictureArrayAlready=false;
    articleInfo.pictures=[[NSMutableArray alloc]init];
    articleInfo.contentAttributedString=nil;
    articleInfo.contentSize=[NSValue valueWithCGSize:getStringSize(articleInfo.content)];
   
    return articleInfo;
}

-(void)articlePreprocess{
    //预加载图片
    [DownloadResourcesUtilities downloadImage:self.user.face_url FromBBS:NO Completed:nil];

    if(self.content!=nil){
        _attributedUtilities=[[AttributedStringUtilities alloc]init];
        _attributedUtilities.delegate=self;
        [self updateAttributedString];
    }
}

-(void)updateAttributedString{
    @synchronized(self) {
        if(self.isPictureArrayAlready){
            for(PictureInfo *picture in self.pictures){
                @synchronized(picture) {
                    if(picture.isDownloaded&&!picture.isShowed){
                        [self _calculateAttributedString];
                        break;
                    }
                }
            }
        }
        else{
            [self _calculateAttributedString];
        }
    }
}
-(void)_calculateAttributedString{
    self.contentAttributedString=[_attributedUtilities getAttributedStringWithArticle:self fontColor:[UIColor blackColor] fontSize:kContentFontSize];
    CGSize boundSize=CGSizeMake(kCustomScreenWidth-2*kMargin, CGFLOAT_MAX);
    self.contentSize=[NSValue valueWithCGSize: sizeThatFitsAttributedString(_contentAttributedString,boundSize,0)];
}


-(void)pictureTapped:(UIGestureRecognizer*)recognizer{
    CustomYYAnimatedImageView *imageView=(CustomYYAnimatedImageView*)recognizer.view;
    if(imageView.isFailed){
        PictureInfo *picture=_pictures[imageView.tag];
        picture.isFailed=NO;
        picture.isDownloading=NO;
        picture.isShowed=NO;
        picture.isDownloaded=NO;
        [self _calculateAttributedString];
        return;
    }
    if(_delegate!=nil)
        [_delegate pictureTapped:recognizer];
}

-(void)addCellObserver{
    if(_delegate!=nil)
        [self addObserver:_delegate forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}
-(void)removeCellObserver{
    if(_delegate!=nil)
        [self removeObserver:_delegate forKeyPath:@"contentSize"];
}
-(void)dealloc{
    [self removeCellObserver];
}
@end
