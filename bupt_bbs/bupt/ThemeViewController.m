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
#import "CustomUtilities.h"
#import <UIImageView+WebCache.h>
#import "AttributedStringUtilities.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import "ScreenAdaptionUtilities.h"
#import "ThemePopoverController.h"

static NSString * const kCellIdentifier=@"articledetailinfo";
static CGFloat const kContentFontSize=15;
static const int kNumOfPageToCache=5;

#define RefreshModePullUp 0
#define RefreshModePullDown 1
#define RefreshModeJump 2

@interface ThemeViewController ()

@property (copy,nonatomic)NSMutableArray*  data;
@property (copy,nonatomic)NSMutableArray*  attributedStringArray;
@property (nonatomic)     int              page_all_count;
@property (nonatomic)     NSRange          pageRange;
@property (nonatomic)     int              page_cur_count;
@property (nonatomic)     int              item_page_count;
@property (nonatomic)     NSUInteger       refreshMode;
@property (strong,nonatomic)UILabel*       titleLabel;
@property (strong,nonatomic)ThemePopoverController *themePopoverController;
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
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8)];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.image=[UIImage imageNamed:@"more"];
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showThemePopoverController)];
    [imageView addGestureRecognizer:recognizer];
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem=barButtonItem;
    
    _pageRange.location=0;
    _pageRange.length=0;
    self.page_all_count=1;
    self.page_cur_count=1;
    self.item_page_count=10;
    
    _data=[[NSMutableArray alloc]init];
    _attributedStringArray=[[NSMutableArray alloc]init];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownToRefresh)];
    self.tableView.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpToRefresh)];
    [self.tableView.mj_footer beginRefreshing];
    
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden=NO;
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
    [cell.faceImageView sd_setImageWithURL:[NSURL URLWithString:articleInfo.user.face_url] placeholderImage:[UIImage imageNamed:@"face_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell refreshCustomLayout];
    }];
    cell.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    cell.timeLabel.text=[CustomUtilities getPostTimeString:articleInfo.post_time];
    cell.nameLabel.text=articleInfo.user.userId;
    cell.contentLabel.attributedText=[AttributedStringUtilities getAttributedStringWithString:articleInfo.content StringColor:[UIColor blackColor] StringSize:kContentFontSize Attachments:articleInfo.attachment];
    cell.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=cell.contentLabel.frame;
    contentLabelNewFrame.size=CGSizeFromString(_attributedStringArray[indexPath.row][@"Size"]);
    cell.contentLabel.frame=contentLabelNewFrame;
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size=CGSizeFromString(_attributedStringArray[indexPath.row][@"Size"]);
    return 3*kMargin+kFaceImageViewHeight+size.height+1;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return  NO;
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
    if(_pageRange.location==0&&_pageRange.length==0)
        nextPage=1;
    else
        nextPage=self.pageRange.location+self.pageRange.length;
    if(nextPage<=self.page_all_count){
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
    }
    else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}
-(void)jumpToRefresh:(NSUInteger) nextPage{
    self.refreshMode=RefreshModeJump;
    [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
}

#pragma mark - 实现AttributedStringDelegate协议
-(void)handleAttribuedStringResponse:(NSArray *)array{
    if(self.refreshMode==RefreshModePullDown){
        [_attributedStringArray insertObjects:array atIndex:0];
        [self.tableView.mj_header endRefreshing];
        _pageRange.location--;
        _pageRange.length++;
        [self.tableView reloadData];
        [self.tableView scrollToRow:_item_page_count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else if(self.refreshMode==RefreshModePullUp){
        [_attributedStringArray insertObjects:array atIndex:_attributedStringArray.count];
        [self.tableView.mj_footer endRefreshing];
        if(_pageRange.location==0&&_pageRange.length==0){
            _pageRange.location=1;
            _pageRange.length=1;
        }
        else
            _pageRange.length++;
        [self.tableView reloadData];
    }
    else if(self.refreshMode==RefreshModeJump){
        [_attributedStringArray removeAllObjects];
        [_attributedStringArray addObjectsFromArray:array];
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
            [_attributedStringArray removeObjectsInRange:range];
            [self.tableView reloadData];
            _pageRange.length--;
            [self.tableView scrollToRow:_item_page_count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else{
            NSRange range=NSMakeRange(0, _item_page_count);
            [_data removeObjectsInRange:range];
            [_attributedStringArray removeObjectsInRange:range];
            [self.tableView reloadData];
            _pageRange.location++;
            _pageRange.length--;
            [self.tableView scrollToRow:(kNumOfPageToCache-1)*_item_page_count-1 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
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
    [AttributedStringUtilities getAttributedStringsWithArray:tmp StringColor:[UIColor blackColor] StringSize:kContentFontSize BoundSize:CGSizeMake(kCustomScreenWidth-2*kMargin, 10000) Delegate:self];
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
        [self.view addSubview:self.themePopoverController.view];
    }
    else{
        [self hideThemePopoverController];
    }
}
#pragma mark - 实现ThemePopoverControllerDelegate协议
-(void)hideThemePopoverController{
    if(self.themePopoverController!=nil){
        [self.themePopoverController hideThemePopoverControllerView];
        self.themePopoverController=nil;
    }
}
@end
