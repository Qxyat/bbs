//
//  ThemeViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ThemeViewController.h"
#import "ThemeUtilities.h"
#import "ArticleInfo.h"
#import "ArticleDetailInfoCell.h"
#import "UserInfo.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import "ScreenAdaptionUtilities.h"
#import "ThemePopoverController.h"
#import "JumpPopoverController.h"
#import "ArticlePreProcessingUtilities.h"
#import "CustomUtilities.h"
#import "PictureInfo.h"

static NSString * const kCellIdentifier=@"articledetailinfo";
static const int kNumOfPageToCache=5;

#define RefreshModePullUp 0
#define RefreshModePullDown 1
#define RefreshModeJump 2

@interface ThemeViewController ()

@property (copy,nonatomic)NSMutableArray*  data;
@property (nonatomic)     int              page_all_count;
@property (nonatomic)     NSRange          pageRange;
@property (nonatomic)     int              page_cur_count;
@property (nonatomic)     int              item_page_count;
@property (nonatomic)     NSUInteger       refreshMode;
@property (strong,nonatomic)UILabel*       titleLabel;
@property (strong,nonatomic)ThemePopoverController *themePopoverController;
@property (strong,nonatomic)JumpPopoverController *jumpPopoverController;
@end

@implementation ThemeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleDetailInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.titleLabel.font=[UIFont systemFontOfSize:14];
    self.titleLabel.numberOfLines=0;
    self.titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView=self.titleLabel;
    
    self.themePopoverController=nil;
    self.jumpPopoverController=nil;
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8)];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.image=[UIImage imageNamed:@"more"];
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showThemePopoverController)];
    [imageView addGestureRecognizer:recognizer];
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem=barButtonItem;
    
    _pageRange.location=0;
    _pageRange.length=0;
    self.page_all_count=0;
    self.page_cur_count=0;
    self.item_page_count=10;
    
    _data=[[NSMutableArray alloc]init];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownToRefresh)];
    self.tableView.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpToRefresh)];
    [self jumpToRefresh:1];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    //设置进入图片浏览器后返回栏的样式
    UIBarButtonItem *backBarButtonItem=[[UIBarButtonItem alloc]init];
    backBarButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=backBarButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideJumpPopoverController];
    [self hideThemePopoverController];
    [SVProgressHUD dismiss];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];//为了解决MWPhotoBrowser不能重用的问题
}
#pragma mark - UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleDetailInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ArticleInfo *articleInfo=_data[indexPath.row];
    cell.articleInfo=articleInfo;
    cell.delegate=self;
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleInfo *articleInfo=_data[indexPath.row];
    CGSize size=[articleInfo.contentSize CGSizeValue];
    return 3*kMargin+kFaceImageViewHeight+size.height+1;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return  NO;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    _page_cur_count=(int)(_pageRange.location+indexPath.row/_item_page_count);
}
#pragma mark - 根据刷新方式刷新页面的内容
-(void)pullDownToRefresh{
    self.refreshMode=RefreshModePullDown;
    NSUInteger nextPage=self.pageRange.location-1;
    if(nextPage>=1)
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
    else{
        [self.tableView.mj_header endRefreshing];
    }
}
-(void)pullUpToRefresh{
    self.refreshMode=RefreshModePullUp;
    NSUInteger nextPage;
    
    nextPage=self.pageRange.location+self.pageRange.length;
    if(nextPage<=self.page_all_count){
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
    }
    else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    
    self.titleLabel.text=response[@"title"];
    NSArray *tmp=[ArticleInfo getArticlesInfo:dic[@"article"]];
    self.page_all_count=[dic[@"pagination"][@"page_all_count"] intValue];
    self.page_cur_count=[dic[@"pagination"][@"page_current_count"] intValue];
    if(self.refreshMode==RefreshModePullDown){
        [_data insertObjects:tmp atIndex:0];
    }
    else if(self.refreshMode==RefreshModePullUp){
        [_data insertObjects:tmp atIndex:_data.count];
    }
    else if(self.refreshMode==RefreshModeJump){
        [_data removeAllObjects];
        [_data addObjectsFromArray:tmp];
    }
    [ArticlePreProcessingUtilities onePageArticlesPreProcess:tmp];
    
    if(self.refreshMode==RefreshModePullDown){
        [self.tableView.mj_header endRefreshing];
        _pageRange.location--;
        _pageRange.length++;
        [self.tableView reloadData];
        [self.tableView scrollToRow:_item_page_count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else if(self.refreshMode==RefreshModePullUp){
        [self.tableView.mj_footer endRefreshing];
        
        _pageRange.length++;
        [self.tableView reloadData];
    }
    else if(self.refreshMode==RefreshModeJump){
        [SVProgressHUD dismiss];
        _pageRange.location=self.page_cur_count;
        _pageRange.length=1;
        [self.tableView reloadData];
        [self.tableView scrollToRow:0 inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    //出于防止内存溢出的BUG，使得data和attributedStringArray里面保存的数据不要超过kNumOfPageToCache页,并且需要考虑页面连续
    if(_pageRange.length>kNumOfPageToCache){
        if(self.refreshMode==RefreshModePullDown){
            NSRange range=NSMakeRange(kNumOfPageToCache*_item_page_count, _data.count%_item_page_count==0?_item_page_count:_data.count%_item_page_count);
            [_data removeObjectsInRange:range];
            [self.tableView reloadData];
            _pageRange.length--;
            [self.tableView scrollToRow:_item_page_count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else{
            NSRange range=NSMakeRange(0, _item_page_count);
            [_data removeObjectsInRange:range];
            [self.tableView reloadData];
            _pageRange.location++;
            _pageRange.length--;
            [self.tableView scrollToRow:(kNumOfPageToCache-1)*_item_page_count-1 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
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
    if(self.refreshMode==RefreshModePullDown)
        [self.tableView.mj_header endRefreshing];
    else if(self.refreshMode==RefreshModePullUp)
        [self.tableView.mj_footer endRefreshing];
}

#pragma mark - 显示更多内容页的PopoverController
-(void)showThemePopoverController{
    if(self.themePopoverController==nil){
        self.themePopoverController=[ThemePopoverController getInstance];
        self.themePopoverController.delegate=self;
        self.themePopoverController.navigationBarHeight=kCustomNavigationBarHeight;
        
        [self.tableView.superview addSubview:self.themePopoverController.view];
    }
    else{
        [self hideThemePopoverController];
    }
    [self hideJumpPopoverController];
}
#pragma mark - 实现ThemePopoverControllerDelegate协议
-(void)hideThemePopoverController{
    if(self.themePopoverController!=nil){
        [self.themePopoverController hideThemePopoverControllerView];
        self.themePopoverController=nil;
    }
}
-(void)showJumpPopoverController{
    [self hideThemePopoverController];
    if(self.jumpPopoverController==nil){
        self.jumpPopoverController=[JumpPopoverController getInstance];
        self.jumpPopoverController.delegate=self;
        self.jumpPopoverController.navigationBarHeight=kCustomNavigationBarHeight;
        self.jumpPopoverController.page_all_count=self.page_all_count;
        self.jumpPopoverController.page_cur_count=self.page_cur_count;
        [self.tableView.superview addSubview:self.jumpPopoverController.view];
    }
    else{
        [self hideJumpPopoverController];
    }
}
#pragma mark - 实现JumpPopoverControllerDelegate协议
-(void)hideJumpPopoverController{
    if(self.jumpPopoverController!=nil){
        [self.jumpPopoverController hideJumpPopoverControllerView];
        self.jumpPopoverController=nil;
    }
}
-(void)jumpToRefresh:(NSUInteger) nextPage{
    [self hideJumpPopoverController];
    self.refreshMode=RefreshModeJump;
    [SVProgressHUD showWithStatus:@"页面加载中"];
    [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
}

#pragma mark - 实现RefreshTableViewDelegate协议
-(void)refreshTableView:(NSString*)url{
    NSArray *paths=[self.tableView indexPathsForVisibleRows];
    
    for(int i=0;i<paths.count;i++){
        NSIndexPath *indexPath=paths[i];
        ArticleInfo *articleInfo=self.data[indexPath.row];
        for(int j=0;j<articleInfo.pictures.count;j++){
            PictureInfo *picture=articleInfo.pictures[j];
            if([url isEqualToString:picture.thumbnail_url]){
                [self.tableView reloadData];
                return;
            }
        }
    }
}
@end
