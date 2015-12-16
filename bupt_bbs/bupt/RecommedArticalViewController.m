//
//  RecommedArticalViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/1.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "RecommedArticalViewController.h"
#import <MJRefresh.h>
#import "RecommedUtilities.h"
#import "ArticleInfo.h"
#import "ArticleInfoCell.h"
#import "ThemeViewController.h"
#import "UserInfo.h"
#import "RootViewController.h"
#import <UIButton+WebCache.h>
#import "LoginConfiguration.h"

static CGFloat const kMargin=20;
static CGFloat const kRowMargin=kMargin/2;
static NSString *const kCellIdentifier=@"cell";

@interface RecommedArticalViewController ()

@property (strong,nonatomic) NSArray *data;
@property (nonatomic) CGFloat screenWidth;
@end

@implementation RecommedArticalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenWidth=[UIScreen mainScreen].bounds.size.width;
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.tableView.mj_header beginRefreshing];
    
    UIButton *button=[[UIButton alloc]init];
    button.frame=CGRectMake(0, 0, 40, 40);
    button.layer.cornerRadius=20;
    button.layer.masksToBounds=YES;
    [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[LoginConfiguration getInstance].loginUserInfo.face_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"face_default"]];
    UIBarButtonItem *leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=leftBarButtonItem;
}

#pragma mark - 显示用户个人中心
-(void)showLeft{
    RootViewController *rootViewController=(RootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController showLeft];
}

#pragma mark - 实现UITableview Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
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
    bottemRect.origin.y=2*kRowMargin+titleRect.size.height;
    cell.bottomView.frame=bottemRect;
    
    cell.boardLabel.text=articleInfo.board_name;
    cell.nameLabel.text=articleInfo.user.user_name;
    cell.replyCountLabel.text=[NSString stringWithFormat:@"%d",articleInfo.reply_count];
    
    return cell;
}
#pragma mark - UITableView Delegate
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
#pragma mark - 刷新推荐文章数据
-(void)refresh{
    [RecommedUtilities getRecommendArticles:self];
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    self.data=[ArticleInfo getArticlesInfo:dic[@"article"]];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - 获取每个cell的文章标题的框体大小
-(CGRect)getTitleFrameSize:(NSString*)aStr{
    CGSize max=CGSizeMake(self.screenWidth-2*kMargin, 80);
    
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    return [aStr boundingRectWithSize:max options:options attributes:attributes context:nil];
}
@end
