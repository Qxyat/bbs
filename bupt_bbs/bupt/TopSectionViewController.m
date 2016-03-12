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
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"
#import "HttpResponseDelegate.h"
#import "UserInfo.h"
#import <SVProgressHUD.h>

@interface TopSectionViewController ()<HttpResponseDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (copy,nonatomic) NSArray* data;
@property (strong,nonatomic) UICollectionView *collectionView;

@end

@implementation TopSectionViewController

+(instancetype)getInstance{
    TopSectionViewController *topSectionViewController=[[TopSectionViewController alloc] init];
    return topSectionViewController;
}
-(void)loadView{
    [super loadView];
    
    self.collectionView=[[UICollectionView alloc]initWithFrame:kCustomScreenBounds collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
    self.collectionView.backgroundColor=[UIColor whiteColor];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    
    [self.view addSubview:self.collectionView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavigationItem];
    
    [self.collectionView registerClass:[SectionAndBoardInfoCell class] forCellWithReuseIdentifier:@"cell"];
    UICollectionViewLayout *layout=self.collectionView.collectionViewLayout;
    UICollectionViewFlowLayout *flow=(UICollectionViewFlowLayout*)layout;
    flow.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.collectionView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.collectionView.mj_header beginRefreshing];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden=NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.tabBarController.tabBar.hidden=YES;
}

#pragma mark - 初始化NavigationItem
-(void)_initNavigationItem{
    self.navigationItem.title=@"全部讨论区";
    UIButton *button=[[UIButton alloc]init];
    button.frame=CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8);
    button.layer.cornerRadius=(kCustomNavigationBarHeight-8)/2;
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
-(void)handleHttpSuccessWithResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    self.data=[SectionInfo getSectionsInfo:dic[@"section"]];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView reloadData];
}
-(void)handleHttpErrorWithResponse:(id)response
                         withError:(NSError *)error{
    NSString *errorString=[CustomUtilities getNetworkErrorInfoWithResponse:response withError:error];
    [SVProgressHUD showErrorWithStatus:errorString];}
@end
