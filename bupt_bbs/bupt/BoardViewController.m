//
//  BoardViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardUtilities.h"
#import "ArticleInfo.h"
#import "BoardArticleInfoCell.h"
#import "UserInfo.h"
#import "ThemeViewController.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"
#import "CustomPopoverController.h"
#import "JumpPopoverController.h"
#import "HttpResponseDelegate.h"

#import <MJRefresh.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <SVProgressHUD.h>

static NSString* const kCellIdentifier=@"cell";

@interface BoardViewController ()<CustomPopoverControllerDelegate,JumpPopoverControllerDelegate,HttpResponseDelegate>

@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *board_description;
@property (nonatomic)BOOL couldBack;
@property (strong,nonatomic)NSArray *data;
@property (nonatomic)int page_all_count;
@property (nonatomic)int page_current_count;
@property (nonatomic)int item_page_count;
@property (nonatomic)int item_all_count;
@property (strong,nonatomic)CustomPopoverController *customPopoverController;
@property (strong,nonatomic)JumpPopoverController *jumpPopoverController;
@property (strong,nonatomic)UIFont *titleLabelFont;
@property (strong,nonatomic)UIFont *posterLabelFont;

@end

@implementation BoardViewController

+(instancetype)getInstanceWithBoardName:(NSString *)name
                   withBoardDescription:(NSString *)board_description
                          withCouldBack:(BOOL)couldBack{
    BoardViewController *boardViewController=[[BoardViewController alloc]init];
    boardViewController.name=name;
    boardViewController.board_description=board_description;
    boardViewController.couldBack=couldBack;
    return boardViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavigationItem];
    
    self.page_current_count=1;
    self.item_page_count=30;
    
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideCustomPopoverController];
    [self hideJumpPopoverController];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!_couldBack)
        self.tabBarController.tabBar.hidden=NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(!_couldBack)
        self.tabBarController.tabBar.hidden=YES;
}
#pragma mark - 初始化NavigationItem
-(void)_initNavigationItem{
    self.navigationItem.title=_board_description;
    
    if(_couldBack){
        UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]init];
        barButtonItem.title=@"";
        self.navigationItem.backBarButtonItem=barButtonItem;
    }
    
    {
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8)];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.image=[UIImage imageNamed:@"more"];
        UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_showCustomPopoverController)];
        [imageView addGestureRecognizer:recognizer];
        UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:imageView];
        self.navigationItem.rightBarButtonItem=barButtonItem;
    }
}


#pragma mark - 显示和隐藏CustomPopoverController
-(void)_showCustomPopoverController{
    [self hideJumpPopoverController];
    if(_customPopoverController==nil){
        CGFloat yOffset=CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGRect frame=CGRectMake(0, yOffset, kCustomScreenWidth,kCustomScreenHeight-yOffset);
        NSArray *pictures=@[@{CustomPopoverControllerImageTypeNormal:@"btn_jump_n",CustomPopoverControllerImageTypeHighlighted: @"btn_jump_h"}];
        _customPopoverController=[CustomPopoverController getInstanceWithFrame:frame withItemNames:@[@"跳页"] withItemPictures:pictures withDelegate:self];
        [self.tableView.superview addSubview:_customPopoverController.view];
    }
    else{
        [self hideCustomPopoverController];
    }
}

#pragma mark -实现JumpPopoverControllerDelegate
-(void)hideJumpPopoverController{
    if(_jumpPopoverController!=nil){
        [_jumpPopoverController hideJumpPopoverControllerView];
        _jumpPopoverController=nil;
    }
}
-(void)jumpToRefresh:(NSUInteger)nextPage{
    [self hideJumpPopoverController];
    _page_current_count=(int)nextPage;
    [self refresh];
}


#pragma mark - 实现CustomPopoverControllerDelegate
-(void)hideCustomPopoverController{
    if(_customPopoverController!=nil){
        [_customPopoverController hideCustomPopoverControllerView];
        _customPopoverController=nil;
    }
}
-(void)itemTapped:(NSInteger)index{
    [self hideCustomPopoverController];
    if(index==0){
        if(_jumpPopoverController==nil){
            _jumpPopoverController=[JumpPopoverController getInstanceWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), kCustomScreenWidth, kCustomScreenHeight-CGRectGetMaxY(self.navigationController.navigationBar.frame)) withPageAllCount:_page_all_count withPageCurCount:_page_current_count withDelegate:self];
            [self.tableView.superview addSubview:_jumpPopoverController.view];
        }
        else{
            [self hideJumpPopoverController];
        }
    }
}

#pragma mark - 刷新
-(void)refresh{
    [BoardUtilities getBoardWithName:self.name Mode:2 Count:self.item_page_count Page:self.page_current_count Delegate:self];
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
    
    self.page_all_count=[dic[@"pagination"][@"page_all_count"] intValue];
    self.page_current_count=[dic[@"pagination"][@"page_current_count"] intValue];
    self.item_page_count=[dic[@"pagination"][@"item_page_count"] intValue];
    self.item_all_count=[dic[@"pagination"][@"item_all_count"] intValue];
    
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
