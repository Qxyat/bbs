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
#import "ScreenAdaptionUtilities.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "CustomUtilities.h"
#import <SVProgressHUD.h>

static NSString* const kCellIdentifier=@"cell";

@interface BoardViewController ()

@property (strong,nonatomic)NSArray *data;
@property (nonatomic)int page_all_count;
@property (nonatomic)int page_curent_count;
@property (nonatomic)int item_page_count;
@property (nonatomic)int item_all_count;
@property (strong,nonatomic)UIFont *titleLabelFont;
@property (strong,nonatomic)UIFont *posterLabelFont;
@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=self.board_description;
    self.page_curent_count=1;
    self.item_page_count=30;
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]init];
    barButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=barButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BoardArticleInfoCell" bundle:nil]
     forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    if(isIPhone6OrIPhone6s){
        self.titleLabelFont=[UIFont systemFontOfSize:kIPhone6TitleLabelFontSize];
        self.posterLabelFont=[UIFont systemFontOfSize:kIPhone6BoardLabelFontSize];
    }
    else if(isIPhone6PlusOrIPhone6sPlus){
        self.titleLabelFont=[UIFont systemFontOfSize:kIPhone6PlusTitleLabelFontSize];
        self.posterLabelFont=[UIFont systemFontOfSize:kIPhone6PlusBoardLabelFontSize];
    }
    else{
        self.titleLabelFont=[UIFont systemFontOfSize:kIPhone5TitleLabelFontSize];
        self.posterLabelFont=[UIFont systemFontOfSize:kIPhone5BoardLabelFontSize];
    }
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 刷新
-(void)refresh{
    [BoardUtilities getBoardWithName:self.name Mode:2 Count:self.item_page_count Page:self.page_curent_count Delegate:self];
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
    cell.titleLabel.font=self.titleLabelFont;
    cell.posterTitleLabel.font=self.posterLabelFont;
    cell.posterContentLabel.font=self.posterLabelFont;
    cell.replyCountLabel.font=self.posterLabelFont;
    cell.replyImageView.image=[UIImage imageNamed:@"reply"];
    cell.titleLabel.text=articleInfo.title;
    cell.posterContentLabel.text=articleInfo.user.user_name;
    cell.replyCountLabel.text=[NSString stringWithFormat:@"%d",articleInfo.reply_count];
    
    return cell;
}


#pragma mark - UITableview Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:kCellIdentifier configuration:^(id cell) {
        ArticleInfo *articleInfo=self.data[indexPath.row];
        BoardArticleInfoCell *boardArticleInfoCell=(BoardArticleInfoCell*)cell;
        boardArticleInfoCell.titleLabel.font=self.titleLabelFont;
        boardArticleInfoCell.posterTitleLabel.font=self.posterLabelFont;
        boardArticleInfoCell.titleLabel.text=articleInfo.title;
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleInfo *articleInfo=self.data[indexPath.row];
    ThemeViewController *themeViewController=[ThemeViewController getInstanceWithBoardName:articleInfo.board_name withGroupId:articleInfo.group_id];
    [self.navigationController pushViewController:themeViewController animated:YES];
}


#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    NSDictionary *dic=(NSDictionary *)response;
    self.data=[ArticleInfo getArticlesInfo:dic[@"article"]];
    
    self.page_all_count=[dic[@"pegination"][@"page_all_count"] intValue];
    self.page_curent_count=[dic[@"pegination"][@"page_cur_count"] intValue];
    self.item_page_count=[dic[@"pegination"][@"item_page_count"] intValue];
    self.item_all_count=[dic[@"pegination"][@"item_all_count"] intValue];
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
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
