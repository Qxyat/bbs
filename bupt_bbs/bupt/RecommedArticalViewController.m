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
#import "ArticleRoughInfoCell.h"
#import "ThemeViewController.h"
#import "UserInfo.h"
#import "RootViewController.h"
#import <UIButton+WebCache.h>
#import "LoginManager.h"
#import "ScreenAdaptionUtilities.h"
#import <UITableView+FDTemplateLayoutCell.h>
static NSString *const kCellIdentifier=@"cell";

@interface RecommedArticalViewController ()

@property (strong,nonatomic) NSArray *data;
@property (strong,nonatomic) UIFont * titleLabelFont;
@property (strong,nonatomic) UIFont * boardLabelFont;
@end

@implementation RecommedArticalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleRoughInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];

    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.tableView.mj_header beginRefreshing];
    
    if(isIPhone6OrIPhone6s){
        self.titleLabelFont=[UIFont systemFontOfSize:kIPhone6TitleLabelFontSize];
        self.boardLabelFont=[UIFont systemFontOfSize:kIPhone6BoardLabelFontSize];
    }
    else if(isIPhone6PlusOrIPhone6sPlus){
        self.titleLabelFont=[UIFont systemFontOfSize:kIPhone6PlusTitleLabelFontSize];
        self.boardLabelFont=[UIFont systemFontOfSize:kIPhone6PlusBoardLabelFontSize];
    }
    else{
        self.titleLabelFont=[UIFont systemFontOfSize:kIPhone5TitleLabelFontSize];
        self.boardLabelFont=[UIFont systemFontOfSize:kIPhone5BoardLabelFontSize];
    }
    
    UIButton *button=[[UIButton alloc]init];
    button.frame=CGRectMake(0, 0, kNavigationBarHeight-8, kNavigationBarHeight-8);
    button.layer.cornerRadius=(kNavigationBarHeight-8)/2;
    button.layer.masksToBounds=YES;
    [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].currentLoginUserInfo.face_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"face_default"]];
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
    ArticleRoughInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ArticleInfo *articleInfo=self.data[indexPath.row];
    cell.titleLabel.font=self.titleLabelFont;
    cell.boardTitleLabel.font=self.boardLabelFont;
    cell.boardContentLabel.font=self.boardLabelFont;
    cell.posterTitleLabel.font=self.boardLabelFont;
    cell.posterContentLabel.font=self.boardLabelFont;
    cell.replyCountLabel.font=self.boardLabelFont;
    
    cell.titleLabel.text=articleInfo.title;
    cell.boardContentLabel.text=articleInfo.board_name;
    cell.posterContentLabel.text=articleInfo.user.user_name;
    cell.replyCountImageView.image=[UIImage imageNamed:@"reply"];
    cell.replyCountLabel.text=[NSString stringWithFormat:@"%d",articleInfo.reply_count];
    
    return cell;
}
#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:kCellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        ArticleRoughInfoCell *articleRoughInfoCell=(ArticleRoughInfoCell*)cell;
        ArticleInfo *articleInfo=self.data[indexPath.row];
        articleRoughInfoCell.titleLabel.font=self.titleLabelFont;
        articleRoughInfoCell.titleLabel.text=articleInfo.title;
        articleRoughInfoCell.boardTitleLabel.font=self.boardLabelFont;
    }];
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


@end
