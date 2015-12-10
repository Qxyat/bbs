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

static NSString * const kCellIdentifier=@"articledetailinfo";

#define PullUpOrientation 0
#define PullDownOrientation 1

@interface ThemeViewController ()

@property (copy,nonatomic)NSMutableArray*  data;
@property (copy,nonatomic)NSMutableArray*  attributedStringArray;
@property (nonatomic)     int              page_all_count;
@property (nonatomic)     NSRange          pageRange;
@property (nonatomic)     int              page_cur_count;
@property (nonatomic)     int              item_page_count;
@property (nonatomic)     NSUInteger       pullOrientation;
@end

@implementation ThemeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleDetailInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    //self.navigationItem.title=self.theme_title;
    
        
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [cell.faceImageView sd_setImageWithURL:[NSURL URLWithString:articleInfo.user.face_url] placeholderImage:[UIImage imageNamed:@"face_default.png"]];
    cell.timeLabel.text=[CustomUtilities getTimeString:articleInfo.post_time];
    cell.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    [cell.replyButton setTitle:articleInfo.user.userId forState:UIControlStateNormal];
    cell.nameLabel.text=articleInfo.user.userId;
    cell.contentLabel.attributedText=_attributedStringArray[indexPath.row][@"AttributedString"];
    cell.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=cell.contentLabel.frame;
    contentLabelNewFrame.size=CGSizeFromString(_attributedStringArray[indexPath.row][@"Size"]);
    cell.contentLabel.frame=contentLabelNewFrame;
    cell.userInteractionEnabled=NO;
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size=CGSizeFromString(_attributedStringArray[indexPath.row][@"Size"]);
    return 65+size.height;
}

#pragma mark - 根据刷新方向刷新页面的内容
-(void)pullDownToRefresh{
    self.pullOrientation=PullDownOrientation;
    int nextPage=self.pageRange.location-1;
    if(nextPage>=1)
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:nextPage countOfOnePage:self.item_page_count delegate:self];
    else{
        [self.tableView.mj_header endRefreshing];
    }
}
-(void)pullUpToRefresh{
    self.pullOrientation=PullUpOrientation;
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

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    
    NSArray *tmp=[ArticleInfo getArticlesInfo:dic[@"article"]];
    self.page_all_count=[dic[@"pagination"][@"page_all_count"] intValue];
    self.page_cur_count=[dic[@"pagination"][@"page_curent_count"] intValue];
    if(self.pullOrientation==PullDownOrientation){
        [_data insertObjects:tmp atIndex:0];
    }
    else{
        [_data insertObjects:tmp atIndex:_data.count];
    }
    [AttributedStringUtilities getAttributedStringsWithArray:tmp StringColor:[UIColor blackColor] StringSize:17 BoundSize:CGSizeMake(300, 10000) Delegate:self];
}

#pragma mark - 实现AttributedStringDelegate协议
-(void)handleAttribuedStringResponse:(NSArray *)array{
    if(self.pullOrientation==PullDownOrientation){
        [_attributedStringArray insertObjects:array atIndex:0];
        [self.tableView.mj_header endRefreshing];
        _pageRange.location--;
        _pageRange.length++;
    }
    else{
        [_attributedStringArray insertObjects:array atIndex:_attributedStringArray.count];
        [self.tableView.mj_footer endRefreshing];
        if(_pageRange.location==0&&_pageRange.length==0){
            _pageRange.location=1;
            _pageRange.length=1;
        }
        else
            _pageRange.length++;
    }
    //出于防止内存溢出的BUG，使得data和attributedStringArray里面保存的数据不要超过5页,并且需要考虑页面连续
    [self.tableView reloadData];
    if(_pageRange.length>5){
        if(self.pullOrientation==PullDownOrientation){
            NSRange range=NSMakeRange(50, _data.count%_item_page_count==0?_item_page_count:_data.count%_item_page_count);
            [_data removeObjectsInRange:range];
            [_attributedStringArray removeObjectsInRange:range];
            _pageRange.length--;
            [self.tableView scrollToRow:10 inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else{
            NSRange range=NSMakeRange(0, 10);
            [_data removeObjectsInRange:range];
            [_attributedStringArray removeObjectsInRange:range];
            _pageRange.location++;
            _pageRange.length--;
            [self.tableView scrollToRow:39 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
