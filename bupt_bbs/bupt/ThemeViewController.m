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

static NSString * const kCellIdentifier=@"articledetailinfo";

@interface ThemeViewController ()

@property (strong,nonatomic)NSArray *data;

@end

@implementation ThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleDetailInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    [self refresh];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleDetailInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ArticleInfo *articleInfo=self.data[indexPath.row];
    cell.timeLabel.text=[NSString stringWithFormat:@"%d",articleInfo.post_time];
    cell.floorLabel.text=[NSString stringWithFormat:@"%d",articleInfo.position];
    cell.nameLabel.text=articleInfo.user.userId;
    cell.contentLabel.text=articleInfo.content;
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark - 获取主题当前页的内容
-(void)refresh{
    [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:self.page countOfOnePage:self.count delegate:self];
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    self.navigationItem.title=dic[@"title"];
    self.data=[ArticleInfo getArticlesInfo:response[@"article"]];
    [self.tableView reloadData];
}

@end
