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

static CGFloat const kMargin=20;
static CGFloat const kRowMargin=kMargin/2;

@interface TopTenViewController ()

@property (nonatomic) CGFloat screenWidth;

@end

@implementation TopTenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.screenWidth=[UIScreen mainScreen].bounds.size.width;
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleInfoCell" bundle:nil] forCellReuseIdentifier:@"ArticleInfoCell"];
    
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
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ArticleInfoCell"];
    UILabel *titleLabel=[cell viewWithTag:1];
    UILabel *boardLabel=[cell viewWithTag:2];
    UILabel *userLabel=[cell viewWithTag:3];
    UILabel *replyCountLabel=[cell viewWithTag:4];
    UIView  *bottemView=[cell viewWithTag:5];
    
    ArticleInfo *articleInfo=self.data[indexPath.row];
    
    titleLabel.text=articleInfo.title;
    CGRect titleRect=titleLabel.frame;
    CGRect titleCalRect=[self getTitleFrameSize:articleInfo.title];
    titleRect.origin.x=kMargin;
    titleRect.origin.y=kRowMargin;
    titleRect.size.width=titleCalRect.size.width;
    titleRect.size.height=titleCalRect.size.height;
    titleLabel.frame=titleRect;
    
    CGRect bottemRect=bottemView.frame;
    bottemRect.origin.y=2*kRowMargin+titleRect.size.height;
    bottemView.frame=bottemRect;
    
    boardLabel.text=articleInfo.board_name;
    userLabel.text=articleInfo.user.user_name;
    replyCountLabel.text=[NSString stringWithFormat:@"%d",articleInfo.reply_count];

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

#pragma  mark - 实现填充TableView数据来源的协议ArticleInfoDelegate
-(void)fillArticlesInfo:(NSArray *)array{
    self.data=[ArticleInfo getArticlesInfo:array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - 获取每个cell的文章标题的框体大小
-(CGRect)getTitleFrameSize:(NSString*)aStr{
    CGSize max=CGSizeMake(self.screenWidth-2*kMargin, 80);
    
    NSStringDrawingOptions options=NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    return [aStr boundingRectWithSize:max options:options attributes:attributes context:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
