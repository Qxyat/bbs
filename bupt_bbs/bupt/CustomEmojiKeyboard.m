//
//  CustomEmojiKeyboard.m
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "CustomEmojiKeyboard.h"
#import "CustomEmojiContainerView.h"

#define kCustomScreenWidth [UIScreen mainScreen].bounds.size.width
#define kNumsOfClassicsEmoji    73
#define kNumsOfYouxihouEmoji    42
#define kNumsOfTusijiEmoji      25
#define kNumsOfYangcongtouEmoji 59

static CGFloat   kContainerViewMargin;
static CGFloat   kContainerViewWidthInOnePage;
static CGFloat   kContainerViewHeightInOnePage;
static NSInteger kRowCountForClassicsEmojiInOnePage;
static NSInteger kColCountForClassicsEmojiInOnePage;
static NSInteger kRowCountForOtherEmojiInOnePage;
static NSInteger kColCountForOtherEmojiInOnePage;
static CGFloat   kClassicsEmojiContainerViewWidth;
static CGFloat   kClassicsEmojiContainerViewHeight;
static CGFloat   kOtherEmojiContainerViewWidth;
static CGFloat   kOtherEmojiContainerViewHeight;
static NSInteger kNumsOfPageForClassicsEmoji;
static NSInteger kNumsOfPageForYouxihouEmoji;
static NSInteger kNumsOfPageForTusijiEmoji;
static NSInteger kNumsOfPageForYangcongtouEmoji;
static NSInteger kNumsOfPageForAllEmojiSets;

@interface CustomEmojiKeyboard ()
@property (strong,nonatomic)UITabBar* tabBar;
@property (strong,nonatomic)UIPageControl *pageControl;
@property (strong,nonatomic)UIScrollView *scrollView;
@end

@implementation CustomEmojiKeyboard

-(id)initWithFrame:(CGRect)frame{
    [self preCaluate];
    frame.size.height=10+49+2*kContainerViewMargin+kContainerViewHeightInOnePage;
    frame.size.width=kCustomScreenWidth;
    if(self=[super initWithFrame:frame]){
        self.backgroundColor=[UIColor whiteColor];
        self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kCustomScreenWidth, 2*kContainerViewMargin+kContainerViewHeightInOnePage)];
        self.scrollView.contentSize=CGSizeMake(kNumsOfPageForAllEmojiSets*CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.pagingEnabled=YES;
        self.scrollView.showsHorizontalScrollIndicator=NO;
        self.scrollView.showsVerticalScrollIndicator=NO;
        self.scrollView.delegate=self;
        self.scrollView.backgroundColor=[UIColor clearColor];
        [self addSubview:self.scrollView];
        
        for(int i=0;i<kNumsOfPageForAllEmojiSets;i++){
            [self loadScrollViewPage:i];
        }
        self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), kCustomScreenWidth, 10)];
        self.pageControl.numberOfPages=3;
        [self.pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [self.pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        self.pageControl.userInteractionEnabled=NO;
        self.pageControl.backgroundColor=[UIColor clearColor];
        [self addSubview:self.pageControl];
        
        self.tabBar=[[UITabBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pageControl.frame), kCustomScreenWidth, 49)];
        self.tabBar.items=@[[[UITabBarItem alloc]initWithTitle:@"经典" image:nil tag:0],
                            [[UITabBarItem alloc]initWithTitle:@"悠嘻猴" image:nil tag:1],
                            [[UITabBarItem alloc]initWithTitle:@"兔斯基" image:nil tag:2],
                            [[UITabBarItem alloc]initWithTitle:@"洋葱头" image:nil tag:3]];
        self.tabBar.delegate=self;
        [self.tabBar setBackgroundImage:[[UIImage alloc]init]];
        [self.tabBar setShadowImage:[[UIImage alloc] init]];
        self.tabBar.backgroundColor=[UIColor clearColor];
        [self addSubview:self.tabBar];
        
        [self refreshPageControlAndTabbar:0];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextStrokePath(context);
    
}
-(void)preCaluate{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(kCustomScreenWidth==320){
            kContainerViewWidthInOnePage=300;
            kColCountForOtherEmojiInOnePage=7;
        }
        else if(kCustomScreenWidth==375){
            kContainerViewWidthInOnePage=360;
            kColCountForOtherEmojiInOnePage=8;
        }
        else if(kCustomScreenWidth==414){
            kContainerViewWidthInOnePage=400;
            kColCountForOtherEmojiInOnePage=9;
        }
        kContainerViewMargin=(kCustomScreenWidth-kContainerViewWidthInOnePage)/2;
        kRowCountForOtherEmojiInOnePage=3;
        kRowCountForClassicsEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        kColCountForClassicsEmojiInOnePage=kColCountForOtherEmojiInOnePage+1;
        kClassicsEmojiContainerViewWidth=kContainerViewWidthInOnePage/kColCountForClassicsEmojiInOnePage;
        kClassicsEmojiContainerViewHeight=kClassicsEmojiContainerViewWidth;
        kOtherEmojiContainerViewWidth=kContainerViewWidthInOnePage/kColCountForOtherEmojiInOnePage;
        kOtherEmojiContainerViewHeight=kOtherEmojiContainerViewWidth;
        kContainerViewHeightInOnePage=kRowCountForOtherEmojiInOnePage*kOtherEmojiContainerViewHeight;
        
        //计算一页能显示多少个经典表情，并且需要多少页
        {
            NSInteger nums=kRowCountForClassicsEmojiInOnePage*kColCountForClassicsEmojiInOnePage-1;
            kNumsOfPageForClassicsEmoji=kNumsOfClassicsEmoji/nums+(kNumsOfClassicsEmoji%nums==0?0:1);
        }
        //计算一页能显示多少个悠嘻猴表情，并且需要多少页
        {
            NSInteger nums=kRowCountForOtherEmojiInOnePage*kColCountForOtherEmojiInOnePage-1;
            kNumsOfPageForYouxihouEmoji=kNumsOfYouxihouEmoji/nums+(kNumsOfYouxihouEmoji%nums==0?0:1);
        }
        //计算一页能显示多少个兔斯基表情，并且需要多少页
        {
            NSInteger nums=kRowCountForOtherEmojiInOnePage*kColCountForOtherEmojiInOnePage-1;
            kNumsOfPageForTusijiEmoji=kNumsOfTusijiEmoji/nums+(kNumsOfTusijiEmoji%nums==0?0:1);
        }
        //计算一页能显示多少个洋葱头表情，并且需要多少页
        {
            NSInteger nums=kRowCountForOtherEmojiInOnePage*kColCountForOtherEmojiInOnePage-1;
            kNumsOfPageForYangcongtouEmoji=kNumsOfYangcongtouEmoji/nums+(kNumsOfYangcongtouEmoji%nums==0?0:1);
        }
        kNumsOfPageForAllEmojiSets=kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji+kNumsOfPageForYangcongtouEmoji;
    });
}

#pragma mark - 实现UIScrollViewDelegate协议
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page=(int)self.scrollView.contentOffset.x/(int)CGRectGetWidth(_scrollView.frame);
    [self refreshPageControlAndTabbar:page];
}

#pragma mark - 实现UITabBarDelegate协议
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSInteger page=0;
    if(item.tag==0){
        page=0;
    }
    else if(item.tag==1){
        page=kNumsOfPageForClassicsEmoji;
    }
    else if(item.tag==2){
        page=kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji;
    }
    else if(item.tag==3){
        page=kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji;
    }
    [self scrollToPage:page];
}
#pragma mark - 加载某一页
-(void)loadScrollViewPage:(NSInteger)page{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(page*CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
    UIView *containerView=[[UIView alloc]initWithFrame:CGRectMake(kContainerViewMargin, kContainerViewMargin, kContainerViewWidthInOnePage, kContainerViewHeightInOnePage)];
    
    NSInteger rowCountForEmojiInOnePage=0;
    NSInteger colCountForEmojiInOnePage=0;
    NSInteger numsOfEmojiInOnePage=0;
    NSInteger pageIndexForCurrentEmojiSet=0;
    NSInteger emojiIndexOffsetForCurrentEmojiSet=0;
    NSInteger emojiIndexOffsetForCurrentEmojiSetModify=0;
    NSInteger totalNumsOfEmoji=0;
    NSString *emojiStringFomrat=nil;
    CGFloat emojiContainerViewWidth=0;
    CGFloat emojiContainerViewHeight=0;
    
    if(page<kNumsOfPageForClassicsEmoji){
        rowCountForEmojiInOnePage=kRowCountForClassicsEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForClassicsEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=0;
        totalNumsOfEmoji=kNumsOfClassicsEmoji;
        emojiStringFomrat=@"em%d";
        emojiContainerViewWidth=kClassicsEmojiContainerViewWidth;
        emojiContainerViewHeight=kClassicsEmojiContainerViewHeight;
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji){
        rowCountForEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForOtherEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=1;
        totalNumsOfEmoji=kNumsOfYouxihouEmoji;
        emojiStringFomrat=@"ema%d";
        emojiContainerViewWidth=kOtherEmojiContainerViewWidth;
        emojiContainerViewHeight=kOtherEmojiContainerViewHeight;
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji){
        rowCountForEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForOtherEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=1;
        totalNumsOfEmoji=kNumsOfTusijiEmoji;
        emojiStringFomrat=@"emb%d";
        emojiContainerViewWidth=kOtherEmojiContainerViewWidth;
        emojiContainerViewHeight=kOtherEmojiContainerViewHeight;
    }
    else{
        rowCountForEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForOtherEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji-kNumsOfPageForTusijiEmoji;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=1;
        totalNumsOfEmoji=kNumsOfYangcongtouEmoji;
        emojiStringFomrat=@"emc%d";
        emojiContainerViewWidth=kOtherEmojiContainerViewWidth;
        emojiContainerViewHeight=kOtherEmojiContainerViewHeight;
    }
    
    for(int i=1;i<=MIN(numsOfEmojiInOnePage, totalNumsOfEmoji-emojiIndexOffsetForCurrentEmojiSet);i++){
        NSInteger pos=emojiIndexOffsetForCurrentEmojiSet+i-emojiIndexOffsetForCurrentEmojiSetModify;
        NSInteger row=(i-1)/colCountForEmojiInOnePage;
        NSInteger col=(i-1)%colCountForEmojiInOnePage;
        CustomEmojiContainerView *emojiView=[[CustomEmojiContainerView alloc]initWithFrame:CGRectMake(emojiContainerViewWidth*col, emojiContainerViewWidth*row, emojiContainerViewWidth, emojiContainerViewWidth)];
        emojiView.backgroundColor=[UIColor clearColor];
        emojiView.delegate=self;
        emojiView.imageString=[NSString stringWithFormat:emojiStringFomrat,pos];
        [containerView addSubview:emojiView];
    }
    CustomEmojiContainerView *emojiView=[[CustomEmojiContainerView alloc]initWithFrame:CGRectMake(emojiContainerViewWidth*(colCountForEmojiInOnePage-1), emojiContainerViewHeight*(rowCountForEmojiInOnePage-1), emojiContainerViewWidth, emojiContainerViewHeight)];
    emojiView.delegate=self;
    emojiView.imageString=@"delete";
    emojiView.backgroundColor=[UIColor clearColor];
    [containerView addSubview:emojiView];
    
    [view addSubview:containerView];
    [_scrollView addSubview:view];
}

#pragma mark - 点击tabbar显示某一页
-(void)scrollToPage:(NSInteger)page{
    CGRect rect=_scrollView.bounds;
    rect.origin.x=CGRectGetWidth(rect)*page;
    [_scrollView scrollRectToVisible:rect animated:YES];
    [self refreshPageControlAndTabbar:page];
}
#pragma mark - 刷新Pagecontrol和Tabbar
-(void)refreshPageControlAndTabbar:(NSInteger)page{
    if(page<kNumsOfPageForClassicsEmoji){
        [_tabBar setSelectedItem:_tabBar.items[0]];
        NSInteger pageIndexForCurrentEmojiSet=page;
        _pageControl.numberOfPages=kNumsOfPageForClassicsEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji){
        [_tabBar setSelectedItem:_tabBar.items[1]];
        NSInteger pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji;
        _pageControl.numberOfPages=kNumsOfPageForYouxihouEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji){
        [_tabBar setSelectedItem:_tabBar.items[2]];
        NSInteger pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji;
        _pageControl.numberOfPages=kNumsOfPageForTusijiEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
        
    }
    else{
        [_tabBar setSelectedItem:_tabBar.items[3]];
        NSInteger pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji-kNumsOfPageForTusijiEmoji;
        _pageControl.numberOfPages=kNumsOfPageForYangcongtouEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
    }
}
#pragma  mark - 实现CustomEmojiKeyboardDelegate协议
-(void)addEmojiWithImage:(YYImage *)image withImageString:(NSString *)imageString{
    if(_delegate!=nil){
        [_delegate addEmojiWithImage:image withImageString:imageString];
    }
}
-(void)deleteEmoji{
    if(_delegate!=nil){
        [_delegate deleteEmoji];
    }
}
@end
