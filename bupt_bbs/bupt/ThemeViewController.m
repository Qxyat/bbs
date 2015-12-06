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

@property (copy,nonatomic)NSArray *data;

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
    cell.timeLabel.text=[self getTimeString:articleInfo.post_time];
    cell.floorLabel.text=[NSString stringWithFormat:@"%d",articleInfo.position];
    cell.nameLabel.text=articleInfo.user.userId;
    CGRect contentRect=[self getRectWithString:articleInfo.content];
    contentRect.origin.x=cell.contentLabel.frame.origin.x;
    contentRect.origin.y=cell.contentLabel.frame.origin.y;
    cell.contentLabel.frame=contentRect;
    cell.contentLabel.text=articleInfo.content;
    return cell;
}

#pragma mark - 获取显示当前时间的字符串
-(NSString*)getTimeString:(NSUInteger)timeInterval{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    
    NSDate *today=[[NSDate alloc]init];
    NSTimeInterval secondsPerDay=24*60*60;
    NSDate *yesterday=[today dateByAddingTimeInterval:-secondsPerDay];
    NSDate *dayBeforeYesterday=[today dateByAddingTimeInterval:-2*secondsPerDay];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSString *todayString=[formatter stringFromDate:today];
    NSString *yesterdayString=[formatter stringFromDate:yesterday];
    NSString *dayBeforeYesterdayString=[formatter stringFromDate:dayBeforeYesterday];
    
    NSDate *postTime=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *postTimeString=[formatter stringFromDate:postTime];
    
    NSCalendar *calender=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSInteger units=NSCalendarUnitYear;
    
    if([postTimeString isEqualToString:todayString]){
        [formatter setDateFormat:@"HH:mm"];
    }
    else if([postTimeString isEqualToString:yesterdayString]){
        [formatter setDateFormat:@"昨天 HH:mm"];
    }
    else if([postTimeString isEqualToString:dayBeforeYesterdayString]){
        [formatter setDateFormat:@"前天 HH:mm"];
    }
    else if([[calender components:units fromDate:today]year]==
            [[calender components:units fromDate:postTime]year]){
        [formatter setDateFormat:@"MM-dd"];
    }
    else{
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }
    
    return  [formatter stringFromDate:postTime];
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleInfo *articleInfo=self.data[indexPath.row];
    return 55+[self getRectWithString:articleInfo.content].size.height;
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

#pragma mark - 实现根据字符串获得框体大小的方法
-(CGRect)getRectWithString:(NSString *)string{
    CGSize  maxSize=CGSizeMake(1400, 280);
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *dic=@{NSFontAttributeName:[UIFont systemFontOfSize:17 ]};
    return [string boundingRectWithSize:maxSize options:options attributes:dic context:nil];
}
@end
