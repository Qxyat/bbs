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
#import "SubThemeViewController.h"

static NSString * const kCellIdentifier=@"articledetailinfo";
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
    self.titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=self.titleLabel;
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"jumpButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(jumpToDestinationPagePopover)];
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden=NO;
}

#pragma mark - 打开跳转到指定页面的浮动窗口
-(void)jumpToDestinationPagePopover{
    SubThemeViewController *controller=[SubThemeViewController getInstance];
    controller.page_all_count=_page_all_count;
    controller.themViewController=self;
    controller.preferredContentSize=CGSizeMake(304, 55);
    
    self.wyPopoverController=[[WYPopoverController alloc]initWithContentViewController:controller];
    self.wyPopoverController.delegate=self;
    [self.wyPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES];
}
#pragma mark - 实现WYPopoverControllerDelegate的协议
-(BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)popoverController{
    return YES;
}
-(void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController{
    self.wyPopoverController.delegate=nil;
    self.wyPopoverController=nil;
    
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
    [cell.faceImageView sd_setImageWithURL:[NSURL URLWithString:articleInfo.user.face_url] placeholderImage:[UIImage imageNamed:@"face_default.png"]];
    cell.timeLabel.text=[CustomUtilities getPostTimeString:articleInfo.post_time];
    cell.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    [cell.replyButton setTitle:articleInfo.user.userId forState:UIControlStateNormal];
    cell.nameLabel.text=articleInfo.user.userId;
    cell.contentLabel.attributedText=[AttributedStringUtilities getAttributedStringWithString:articleInfo.content StringColor:[UIColor blackColor] StringSize:17 Attachments:articleInfo.attachment];
    cell.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=cell.contentLabel.frame;
    contentLabelNewFrame.size=CGSizeFromString(_attributedStringArray[indexPath.row][@"Size"]);
    cell.contentLabel.frame=contentLabelNewFrame;
    [cell resignFirstResponder];
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size=CGSizeFromString(_attributedStringArray[indexPath.row][@"Size"]);
    return 65+size.height;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return  NO;
}

#pragma mark - 根据刷新方式刷新页面的内容
-(void)pullDownToRefresh{
    self.refreshMode=RefreshModePullDown;
    int nextPage=self.pageRange.location-1;
    if(nextPage>=1)
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:nextPage countOfOnePage:self.item_page_count delegate:self];
    else{
        [self.tableView.mj_header endRefreshing];
    }
}
-(void)pullUpToRefresh{
    self.refreshMode=RefreshModePullUp;
    int nextPage;
    if(_pageRange.location==0&&_pageRange.length==0)
        nextPage=1;
    else
        nextPage=self.pageRange.location+self.pageRange.length;
    if(nextPage<=self.page_all_count){
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:nextPage countOfOnePage:self.item_page_count delegate:self];
    }
    else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}
-(void)jumpToRefresh:(NSUInteger) nextPage{
    self.refreshMode=RefreshModeJump;
    [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:nextPage countOfOnePage:self.item_page_count delegate:self];
}
#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
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
    [AttributedStringUtilities getAttributedStringsWithArray:tmp StringColor:[UIColor blackColor] StringSize:17 BoundSize:CGSizeMake(300, 10000) Delegate:self];
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
        if(self.wyPopoverController!=nil)
           [self.wyPopoverController dismissPopoverAnimated:YES];
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

#pragma mark - 实现根据字符串获得框体大小的方法
-(CGRect)getRectWithString:(NSString *)string{
    CGSize  maxSize=CGSizeMake(300, 1400);
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *dic=@{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    return [string boundingRectWithSize:maxSize options:options attributes:dic context:nil];
}
@end
