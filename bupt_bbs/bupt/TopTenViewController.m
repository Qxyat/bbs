//
//  TopTenViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/1.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "TopTenViewController.h"
#import "TopTenUtilities.h"
#import "ArticleInfo.h"
#import "UserInfo.h"
#import <MJRefresh.h>
#import "ThemeViewController.h"
#import "ArticleRoughInfoCell.h"
#import "LoginManager.h"
#import <UIButton+WebCache.h>
#import "RootViewController.h"
#import "ScreenAdaptionUtilities.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "CustomUtilities.h"
#import <SVProgressHUD.h>

static NSString *const kCellIdentifier=@"cell";

@interface TopTenViewController ()

@property (copy,nonatomic) NSArray *data;
@property (strong,nonatomic) UIFont * titleLabelFont;
@property (strong,nonatomic) UIFont * boardLabelFont;
@end

@implementation TopTenViewController

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
    button.frame=CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8);
    button.layer.cornerRadius=(kCustomNavigationBarHeight-8)/2;
    button.layer.masksToBounds=YES;
    [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].currentLoginUserInfo.face_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"face_default"]];
    UIBarButtonItem *leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=leftBarButtonItem;
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]init];
    barButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=barButtonItem;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden=NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.tabBarController.tabBar.hidden=YES;
}
#pragma mark - 显示用户个人中心
-(void)showLeft{
    RootViewController *rootViewController=(RootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController showLeft];
}

#pragma mark - 刷新十大消息
-(void)refresh{
    [TopTenUtilities getTopTenArticles:self];
}


#pragma mark - UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.data.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    ArticleInfo *articleInfo=self.data[indexPath.row];
    ThemeViewController *themViewController=[ThemeViewController getInstanceWithBoardName:articleInfo.board_name withGroupId:articleInfo.group_id];
    [self.navigationController pushViewController:themViewController animated:YES];
}

#pragma  mark - 实现HttpResponseDelegate
-(void)handleHttpSuccessResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    self.data=[ArticleInfo getArticlesInfo:dic[@"article"]];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
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
    [self.tableView.mj_header endRefreshing];
}
@end
