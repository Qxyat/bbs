//
//  SectionViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/1.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "TopSectionViewController.h"
#import "SectionUtilities.h"
#import <MJRefresh.h>
#import "SectionInfo.h"
#import "SectionAndBoardInfoCell.h"
#import "SectionViewController.h"
#import <UIButton+WebCache.h>
#import "LoginManager.h"
#import "RootViewController.h"

@interface TopSectionViewController ()
@property (copy,nonatomic) NSArray* data;
@end

@implementation TopSectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor=[UIColor whiteColor];
    [self.collectionView registerClass:[SectionAndBoardInfoCell class] forCellWithReuseIdentifier:@"cell"];
    
    UICollectionViewLayout *layout=self.collectionView.collectionViewLayout;
    UICollectionViewFlowLayout *flow=(UICollectionViewFlowLayout*)layout;
    flow.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.collectionView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.collectionView.mj_header beginRefreshing];

    UIButton *button=[[UIButton alloc]init];
    button.frame=CGRectMake(0, 0, 40, 40);
    button.layer.cornerRadius=20;
    button.layer.masksToBounds=YES;
    [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[LoginManager     sharedManager].currentLoginUserInfo.face_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"face_default"]];
    UIBarButtonItem *leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=leftBarButtonItem;
}
#pragma mark - 显示用户个人中心
-(void)showLeft{
    RootViewController *rootViewController=(RootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController showLeft];
}

#pragma mark - 实现UICollectionView Data Source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  self.data.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SectionAndBoardInfoCell *cell=[self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    SectionInfo *sectionInfo=self.data[indexPath.row];
    cell.label.text=sectionInfo.section_description;
    return cell;
}
#pragma mark - 实现UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SectionViewController *section=[[SectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
    SectionInfo *sectionInfo=self.data[indexPath.row];
    section.name=sectionInfo.name;
    section.section_description=sectionInfo.section_description;
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]init];
    barButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=barButtonItem;

    [self.navigationController pushViewController:section animated:YES];
}

#pragma mark - 实现UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(90, 175);
}

#pragma mark - 获得根分区信息
-(void)refresh{
    [SectionUtilities getSections:self];
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    self.data=[SectionInfo getSectionsInfo:dic[@"section"]];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView reloadData];
}

@end
