//
//  BoardViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SectionViewController.h"
#import <MJRefresh.h>
#import "SectionUtilities.h"
#import "BoardInfo.h"
#import "SectionAndBoardInfoCell.h"
#import "CollectionViewHeader.h"
#import "SectionInfo.h"
#import "BoardViewController.h"
#import "CustomUtilities.h"
#import <SVProgressHUD.h>
static NSString *const kContentCellIdentifier=@"contentCell";
static NSString *const kHeaderCellIdentifier=@"headerCell";
@interface SectionViewController ()

@property (strong,nonatomic)NSArray *section_data;
@property (strong,nonatomic)NSArray *board_data;
@property (nonatomic)       int      numberOfSections;
@end

@implementation SectionViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.collectionView.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=self.section_description;
    
    self.section_data=[[NSArray alloc]init];
    self.board_data=[[NSArray alloc]init];
    _numberOfSections=1;
    [self.collectionView registerClass:[SectionAndBoardInfoCell class] forCellWithReuseIdentifier:kContentCellIdentifier];
    [self.collectionView registerClass:[CollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellIdentifier];
    
    UICollectionViewLayout *layout=self.collectionView.collectionViewLayout;
    UICollectionViewFlowLayout *flow=(UICollectionViewFlowLayout*)layout;
    flow.headerReferenceSize=CGSizeMake(320, 25);
    
    flow.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.collectionView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - 实现UICollectionView Data Source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _numberOfSections;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_numberOfSections==2){
        if(section==0)
            return self.section_data.count;
        else
            return self.board_data.count;
    }
    else if(_numberOfSections==1){
        if(self.section_data.count!=0)
            return  self.section_data.count;
        else
            return self.board_data.count;
    }
    else
        return 0;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SectionAndBoardInfoCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kContentCellIdentifier forIndexPath:indexPath];
    if(_numberOfSections==2){
        if(indexPath.section==0){
            SectionInfo *sectionInfo=self.section_data[indexPath.row];
            cell.label.text=sectionInfo.section_description;
        }
        else{
            BoardInfo *boardInfo=self.board_data[indexPath.row];
            cell.label.text=boardInfo.board_description;
        }
    }
    else{
        if(self.section_data.count!=0){
            SectionInfo *sectionInfo=self.section_data[indexPath.row];
            cell.label.text=sectionInfo.section_description;
        }
        else{
            BoardInfo *boardInfo=self.board_data[indexPath.row];
            cell.label.text=boardInfo.board_description;
        }
    }
    return cell;
}
-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        CollectionViewHeader *cell=[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderCellIdentifier forIndexPath:indexPath];
        if(_numberOfSections==1){
            if(self.section_data.count!=0)
                cell.headerLabel.text=@"子分区列表";
            else
                cell.headerLabel.text=@"版面列表";
        }
        else{
            if(indexPath.section==0)
                cell.headerLabel.text=@"子分区列表";
            else
                cell.headerLabel.text=@"版面列表";
        }
        return cell;
    }
    return  nil;
}

#pragma mark - 实现UICollectionView delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]init];
    barButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=barButtonItem;
    if(_numberOfSections==1){
        if(self.section_data.count!=0){
            SectionViewController *sectionViewController=[[SectionViewController alloc]initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
            SectionInfo *sectionInfo=self.section_data[indexPath.row];
            sectionViewController.name=sectionInfo.name;
            sectionViewController.section_description=sectionInfo.section_description;
            [self.navigationController pushViewController:sectionViewController animated:YES];
        }
        else{
            BoardViewController *boardViewController=[[BoardViewController alloc]init];
            BoardInfo *boardInfo=self.board_data[indexPath.row];
            boardViewController.name=boardInfo.name;
            boardViewController.board_description=boardInfo.board_description;
            [self.navigationController pushViewController:boardViewController animated:YES];
        }
    }
    else{
        if(indexPath.section==0){
            SectionViewController *sectionViewController=[[SectionViewController alloc]initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
            SectionInfo *sectionInfo=self.section_data[indexPath.row];
            sectionViewController.name=sectionInfo.name;
            sectionViewController.section_description=sectionInfo.section_description;
            
            [self.navigationController pushViewController:sectionViewController animated:YES];
        }
        else{
            BoardViewController *boardViewController=[[BoardViewController alloc]init];
            BoardInfo *boardInfo=self.board_data[indexPath.row];
            boardViewController.name=boardInfo.name;
            boardViewController.board_description=boardInfo.board_description;
            [self.navigationController pushViewController:boardViewController animated:YES];
        }
    }
}

#pragma mark - 实现UICollectionViewFlowLayout delegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(90, 175);
}

#pragma mark - 刷新当前分区信息
-(void)refresh{
    [SectionUtilities getSpecifiedSectionsWithName:self.name delegate:self];
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    NSArray *sub_sections=dic[@"sub_section"];
    if(sub_sections.count>0){
        NSMutableArray *tmp=[[NSMutableArray alloc]initWithCapacity:sub_sections.count];
        for(int i=0;i<sub_sections.count;i++){
            SectionInfo *sectionInfo=[[SectionInfo alloc]init];
            sectionInfo.section_description=sub_sections[i];
            sectionInfo.name=sub_sections[i];
            [tmp addObject:sectionInfo];
        }
        self.section_data=tmp;
        [SectionUtilities getSubSectionsWithName:sub_sections delegate:self];
    }
    else
        self.section_data=[[NSArray alloc]init];
    self.board_data=[BoardInfo getBoardsInfo:dic[@"board"]];
    if(self.section_data.count==0||self.board_data.count==0)
        _numberOfSections=1;
    else
        _numberOfSections=2;
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView reloadData];
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
    [self.collectionView.mj_header endRefreshing];
}
-(void)handleSubSectionResponse:(id)response{
    self.section_data=response;
    [self.collectionView reloadData];
}
@end
