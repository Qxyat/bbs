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

static NSString * const kCellIdentifier=@"articledetailinfo";

@interface ThemeViewController ()

@property (copy,nonatomic)NSArray *data;
@property (copy,nonatomic)NSArray *attributedStringArray;
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
    [cell.faceImageView sd_setImageWithURL:[NSURL URLWithString:articleInfo.user.face_url] placeholderImage:[UIImage imageNamed:@"face_default.png"]];
    cell.timeLabel.text=[CustomUtilities getTimeString:articleInfo.post_time];
    cell.floorLabel.text=[CustomUtilities getFloorString:articleInfo.position];
    [cell.replyButton setTitle:articleInfo.user.userId forState:UIControlStateNormal];
    cell.nameLabel.text=articleInfo.user.userId;
    cell.contentLabel.attributedText=self.attributedStringArray[indexPath.row][@"AttributedString"];
    cell.contentLabel.numberOfLines=0;
    CGRect contentLabelNewFrame=cell.contentLabel.frame;
    contentLabelNewFrame.size=CGSizeFromString(self.attributedStringArray[indexPath.row][@"Size"]);
    cell.contentLabel.frame=contentLabelNewFrame;
    cell.userInteractionEnabled=NO;
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size=CGSizeFromString(self.attributedStringArray[indexPath.row][@"Size"]);
    return 65+size.height;
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
    //NSMutableArray *contentArray=[[NSMutableArray alloc]initWithCapacity:self.data.count];
    
    [AttributedStringUtilities getAttributedStringsWithArray:self.data StringColor:[UIColor blackColor] StringSize:17 BoundSize:CGSizeMake(300, 10000) Delegate:self];
}

#pragma mark - 实现AttributedStringDelegate协议
-(void)handleAttribuedStringResponse:(NSArray *)array{
    self.attributedStringArray=array;
    [self.tableView reloadData];
}

#pragma mark - 实现根据字符串获得框体大小的方法
-(CGRect)getRectWithString:(NSString *)string{
    CGSize  maxSize=CGSizeMake(300, 1400);
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *dic=@{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    return [string boundingRectWithSize:maxSize options:options attributes:dic context:nil];
}
@end
