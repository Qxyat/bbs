//
//  BoardViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BoardViewController.h"
#import <MJRefresh.h>
#import "BoardUtilities.h"
#import "ArticleInfo.h"
#import "BoardArticleInfoCell.h"
#import "UserInfo.h"
#import "ThemeViewController.h"

static CGFloat const kMargin=20;
static CGFloat const kRowMargin=kMargin/2;
static NSString* const kCellIdentifier=@"cell";

@interface BoardViewController ()

@property (strong,nonatomic)NSArray *data;
@property (nonatomic)int page_all_count;
@property (nonatomic)int page_curent_count;
@property (nonatomic)int item_page_count;
@property (nonatomic)int item_all_count;
@property (nonatomic) CGFloat screenWidth;
@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=self.board_description;
    self.page_curent_count=1;
    self.item_page_count=30;
    self.screenWidth=[UIScreen mainScreen].bounds.size.width;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BoardArticleInfoCell" bundle:nil]
     forCellReuseIdentifier:kCellIdentifier];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 刷新
-(void)refresh{
    [BoardUtilities getBoardWithName:self.name Mode:2 Count:self.item_page_count Page:self.page_curent_count Delegate:self];
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
    NSDictionary *dic=(NSDictionary *)response;
    self.data=[ArticleInfo getArticlesInfo:dic[@"article"]];
    
    self.page_all_count=[dic[@"pegination"][@"page_all_count"] intValue];
    self.page_curent_count=[dic[@"pegination"][@"page_cur_count"] intValue];
    self.item_page_count=[dic[@"pegination"][@"item_page_count"] intValue];
    self.item_all_count=[dic[@"pegination"][@"item_all_count"] intValue];
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSrource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.data.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BoardArticleInfoCell * cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ArticleInfo *articleInfo=self.data[indexPath.row];
    
    cell.titleLabel.text=articleInfo.title;
    CGRect titleRect=cell.titleLabel.frame;
    CGRect titleCalRect=[self getTitleFrameSize:articleInfo.title];
    titleRect.origin.x=kMargin;
    titleRect.origin.y=kRowMargin;
    titleRect.size.width=titleCalRect.size.width;
    titleRect.size.height=titleCalRect.size.height;
    cell.titleLabel.frame=titleRect;
    
    CGRect bottemRect=cell.bottomView.frame;
    bottemRect.origin.x=kMargin;
    bottemRect.origin.y=2*kRowMargin+titleRect.size.height;
    cell.bottomView.frame=bottemRect;
    
    cell.nameLabel.text=articleInfo.user.user_name;
    cell.replyCountLabel.text=[NSString stringWithFormat:@"%d",articleInfo.reply_count];
    
    return cell;
}
#pragma mark - UITableview Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleInfo *articleInfo=self.data[indexPath.row];
    CGRect calRect=[self getTitleFrameSize:articleInfo.title];
    
    return 3*kRowMargin+calRect.size.height+22;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIEdgeInsets edge=UIEdgeInsetsMake(0, kMargin, 0, kMargin);
    [cell setSeparatorInset:edge];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ThemeViewController *themViewController=[[ThemeViewController alloc]init];
    ArticleInfo *articleInfo=self.data[indexPath.row];
    themViewController.board_name=articleInfo.board_name;
    themViewController.group_id=articleInfo.group_id;
    themViewController.theme_title=articleInfo.title;
    themViewController.tabBarController.tabBar.hidden=YES;
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]init];
    barButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=barButtonItem;
    
    [self.navigationController pushViewController:themViewController animated:YES];
}


#pragma mark - 获取每个cell的文章标题的框体大小
-(CGRect)getTitleFrameSize:(NSString*)aStr{
    CGSize max=CGSizeMake(self.screenWidth-2*kMargin, 80);
    
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    return [aStr boundingRectWithSize:max options:options attributes:attributes context:nil];
}
@end
