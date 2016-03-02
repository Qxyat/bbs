//
//  FavoriteViewControllerTableViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/3/1.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteUtilities.h"
#import "HttpResponseDelegate.h"

#import <MJRefresh.h>

@interface FavoriteViewController ()<HttpResponseDelegate>

@end

@implementation FavoriteViewController

+(instancetype)getInstance{
    return [[FavoriteViewController alloc]init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavigationItem];
    self.tableView.mj_header=[MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshFavorite)];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 初始化NavigationItem
-(void)_initNavigationItem{
    self.navigationItem.title=@"收藏夹";
    
    UIBarButtonItem *leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_cancle)];
    self.navigationItem.leftBarButtonItem=leftBarButtonItem;
}


#pragma mark - 退出收藏页面
-(void)_cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 刷新收藏内容
-(void)refreshFavorite{
    [FavoriteUtilities getFavoriteInfoWithLevel:0 withDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - 实现HttpResponseDelegate
-(void)handleHttpSuccessResponse:(id)response{
    NSLog(@"%@",response);
    [self.tableView.mj_header endRefreshing];
}
-(void)handleHttpErrorResponse:(id)response{
    NSLog(@"%@",response);
    [self.tableView.mj_header endRefreshing];
}

@end
