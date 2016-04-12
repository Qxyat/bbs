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
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import "ScreenAdaptionUtilities.h"
//#import "ThemePopoverController.h"
#import "JumpPopoverController.h"
#import "CustomUtilities.h"
#import "PictureInfo.h"
#import "ReplyViewController.h"
#import "HttpResponseDelegate.h"
//#import "ThemePopoverControllerDelegate.h"
#import "CustomPopoverController.h"
#import "RefreshTableViewDelegate.h"
#import "UserInfoViewController.h"
#import "LoginManager.h"
#import <MWPhotoBrowser.h>

static NSString * const kCellIdentifier=@"articledetailinfo";
static const int kNumOfPageToCache=5;

#define RefreshModePullUp 0
#define RefreshModePullDown 1
#define RefreshModeJump 2

@interface ThemeViewController ()<HttpResponseDelegate,CustomPopoverControllerDelegate,JumpPopoverControllerDelegate,ArticleDetailInfoCellDelegate,UserInfoViewControllerDelegate,ArticleInfoDelegate,MWPhotoBrowserDelegate>

@property (nonatomic) int group_id;
@property (strong,nonatomic) NSString *board_name;
@property (strong,nonatomic) NSString *theme_title;
@property (copy,nonatomic)NSMutableArray*  data;
@property (nonatomic)     int              page_all_count;
@property (nonatomic)     NSRange          pageRange;
@property (nonatomic)     int              page_cur_count;
@property (nonatomic)     int              item_page_count;
@property (nonatomic)     NSUInteger       refreshMode;
@property (strong,nonatomic)UILabel*       titleLabel;
@property (strong,nonatomic)CustomPopoverController *customPopoverController;
@property (strong,nonatomic)JumpPopoverController *jumpPopoverController;
@property (strong,nonatomic)UserInfoViewController *userInfoViewController;

@property (strong,nonatomic)MWPhotoBrowser *photoBrowser;
@property (strong,nonatomic)NSMutableArray *photoBrowserPhotos;

@end

@implementation ThemeViewController
+(instancetype)getInstanceWithBoardName:(NSString *)boardName
                            withGroupId:(int)groupId
{
    ThemeViewController *themeViewController=[[ThemeViewController alloc]init];
    themeViewController.board_name=boardName;
    themeViewController.group_id=groupId;
    return themeViewController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleDetailInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.titleLabel.font=[UIFont systemFontOfSize:14];
    self.titleLabel.numberOfLines=0;
    self.titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView=self.titleLabel;
    
    self.customPopoverController=nil;
    self.jumpPopoverController=nil;
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8)];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.image=[UIImage imageNamed:@"more"];
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCustomPopoverController)];
    [imageView addGestureRecognizer:recognizer];
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem=barButtonItem;
    
    _pageRange.location=0;
    _pageRange.length=0;
    self.page_all_count=0;
    self.page_cur_count=0;
    self.item_page_count=10;
    
    _data=[[NSMutableArray alloc]init];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownToRefresh)];
    self.tableView.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpToRefresh)];
    [self jumpToRefresh:1];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];

    UIBarButtonItem *backBarButtonItem=[[UIBarButtonItem alloc]init];
    backBarButtonItem.title=@"";
    self.navigationItem.backBarButtonItem=backBarButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideJumpPopoverController];
    [self hideCustomPopoverController];
    [self hideUserInfoViewController];
    [SVProgressHUD dismiss];
}

#pragma mark - UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleDetailInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    ArticleInfo *articleInfo=_data[indexPath.row];
   
    cell.articleInfo=articleInfo;
    cell.delegate=self;
    
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   // static int count=0;
    
    ArticleInfo *articleInfo=_data[indexPath.row];
    CGSize size=[articleInfo.contentSize CGSizeValue];
    
//    NSLog(@"**************");
//    NSLog(@"height For Row At IndexPath %@ %d",indexPath,count++);
//    NSLog(@"%@",NSStringFromCGSize(size));
//    NSLog(@"**************");
    
    return 4*kMargin+2*kFaceImageViewHeight+size.height+1;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return  NO;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    _page_cur_count=(int)(_pageRange.location+indexPath.row/_item_page_count);
}

//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//
//}
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    
//}
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
//}

#pragma mark - 根据刷新方式刷新页面的内容
-(void)pullDownToRefresh{
    self.refreshMode=RefreshModePullDown;
    NSUInteger nextPage=self.pageRange.location-1;
    if(nextPage>=1)
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
    else{
        [self.tableView.mj_header endRefreshing];
    }
}

-(void)pullUpToRefresh{
    self.refreshMode=RefreshModePullUp;
    NSUInteger nextPage;
    
    nextPage=self.pageRange.location+self.pageRange.length;
    if(nextPage<=self.page_all_count){
        [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
    }
    else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessWithResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    
    self.theme_title=dic[@"title"];
    self.titleLabel.text=dic[@"title"];
    NSArray *tmp=[ArticleInfo getArticlesInfo:dic[@"article"]];
    for(ArticleInfo *article in tmp){
        [article articlePreprocess];
        article.delegate=self;
    }
    
    self.page_all_count=[dic[@"pagination"][@"page_all_count"] intValue];
    self.page_cur_count=[dic[@"pagination"][@"page_current_count"] intValue];
    
    if(self.refreshMode==RefreshModePullDown){
        [_data insertObjects:tmp atIndex:0];
    }
    else if(self.refreshMode==RefreshModePullUp){
        [_data insertObjects:tmp atIndex:_data.count];
    }
    else if(self.refreshMode==RefreshModeJump){
        [_data removeAllObjects];
        [_data addObjectsFromArray:tmp];
    }
    //[ArticlePreProcessingUtilities onePageArticlesPreProcess:tmp];
    
    if(self.refreshMode==RefreshModePullDown){
        [self.tableView.mj_header endRefreshing];
        _pageRange.location--;
        _pageRange.length++;
        [self.tableView reloadData];
        [self.tableView scrollToRow:_item_page_count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else if(self.refreshMode==RefreshModePullUp){
        [self.tableView.mj_footer endRefreshing];
        
        _pageRange.length++;
        [self.tableView reloadData];
    }
    else if(self.refreshMode==RefreshModeJump){
        [SVProgressHUD dismiss];
        _pageRange.location=self.page_cur_count;
        _pageRange.length=1;
        [self.tableView reloadData];
        [self.tableView scrollToRow:0 inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    //出于防止内存溢出的BUG，使得data和attributedStringArray里面保存的数据不要超过kNumOfPageToCache页,并且需要考虑页面连续
    if(_pageRange.length>kNumOfPageToCache){
        if(self.refreshMode==RefreshModePullDown){
            NSRange range=NSMakeRange(kNumOfPageToCache*_item_page_count, _data.count%_item_page_count==0?_item_page_count:_data.count%_item_page_count);
            [_data removeObjectsInRange:range];
            [self.tableView reloadData];
            _pageRange.length--;
            [self.tableView scrollToRow:_item_page_count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else{
            NSRange range=NSMakeRange(0, _item_page_count);
            [_data removeObjectsInRange:range];
            [self.tableView reloadData];
            _pageRange.location++;
            _pageRange.length--;
            [self.tableView scrollToRow:(kNumOfPageToCache-1)*_item_page_count-1 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}
-(void)handleHttpErrorWithResponse:(id)response
                         withError:(NSError *)error{
    NSString *errorString=[CustomUtilities getNetworkErrorInfoWithResponse:response withError:error];
    [SVProgressHUD showErrorWithStatus:errorString];
    
    if(self.refreshMode==RefreshModePullDown)
        [self.tableView.mj_header endRefreshing];
    else if(self.refreshMode==RefreshModePullUp)
        [self.tableView.mj_footer endRefreshing];
}

#pragma mark - 显示更多内容页的PopoverController
-(void)showCustomPopoverController{
    [self hideJumpPopoverController];
    if(self.customPopoverController==nil){
        CGFloat yOffset=CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGRect frame=CGRectMake(0, yOffset, kCustomScreenWidth,kCustomScreenHeight-yOffset);
        NSArray *pictures=@[@{CustomPopoverControllerImageTypeNormal:@"btn_jump_n",CustomPopoverControllerImageTypeHighlighted: @"btn_jump_h"},@{CustomPopoverControllerImageTypeNormal:@"btn_reply_n",CustomPopoverControllerImageTypeHighlighted:@"btn_reply_h"}];
        _customPopoverController=[CustomPopoverController getInstanceWithFrame:frame withItemNames:@[@"跳页",@"快捷回复"] withItemPictures:pictures withDelegate:self];
        [self.tableView.superview addSubview:_customPopoverController.view];
    }
    else{
        [self hideCustomPopoverController];
    }
//    if(self.themePopoverController==nil){
//        self.themePopoverController=[ThemePopoverController getInstance];
//        self.themePopoverController.delegate=self;
//        self.themePopoverController.navigationBarHeight=kCustomNavigationBarHeight;
//        
//        [self.tableView.superview addSubview:self.themePopoverController.view];
//    }
//    else{
//        [self hideThemePopoverController];
//    }
}
#pragma mark - 实现CustomPopoverControllerDelegate协议
-(void)hideCustomPopoverController{
    if(self.customPopoverController!=nil){
        [self.customPopoverController hideCustomPopoverControllerView];
        self.customPopoverController=nil;
    }
}
-(void)itemTapped:(NSInteger)index{
    [self hideCustomPopoverController];
    if(index==0){
        if(self.jumpPopoverController==nil){
            self.jumpPopoverController=[JumpPopoverController getInstanceWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), kCustomScreenWidth, kCustomScreenHeight-CGRectGetMaxY(self.navigationController.navigationBar.frame)) withPageAllCount:_page_all_count withPageCurCount:_page_cur_count withDelegate:self];
            [self.tableView.superview addSubview:self.jumpPopoverController.view];
        }
        else{
            [self hideJumpPopoverController];
        }
    }
    else if(index==1){
        ReplyViewController *viewController=[ReplyViewController getInstanceWithBoardName:self.board_name isNewTheme:NO withArticleName:self.theme_title withArticleId:self.group_id withArticleInfo:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - 实现JumpPopoverControllerDelegate协议
-(void)hideJumpPopoverController{
    if(self.jumpPopoverController!=nil){
        [self.jumpPopoverController hideJumpPopoverControllerView];
        self.jumpPopoverController=nil;
    }
}
-(void)jumpToRefresh:(NSUInteger) nextPage{
    [self hideJumpPopoverController];
    self.refreshMode=RefreshModeJump;
    [SVProgressHUD showWithStatus:@"页面加载中"];
    [ThemeUtilities getThemeWithBoardName:self.board_name groupId:self.group_id pageIndex:(int)nextPage countOfOnePage:self.item_page_count delegate:self];
}

#pragma mark - 实现ArticleDetailInfoCellDelegate协议
-(void)showUserInfoViewController:(UserInfo *)userInfo{
    _userInfoViewController=[UserInfoViewController getInstanceWithUserInfo:userInfo Delegate:self];
    [[UIApplication sharedApplication].keyWindow addSubview:_userInfoViewController.view];
}

-(void)showReplyViewControllerWithBoardName:(NSString *)board_name
                                 isNewTheme:(Boolean)isNewTheme
                                ArtilceName:(NSString *)article_name
                                  ArticleID:(NSInteger)articleID
                                ArticleInfo:(ArticleInfo *)articleInfo{
    [self.navigationController pushViewController:[ReplyViewController getInstanceWithBoardName:board_name isNewTheme:isNewTheme withArticleName:article_name withArticleId:articleID withArticleInfo:articleInfo] animated:YES];
}

#pragma mark - 实现UserInfoViewControllerDelegate协议
-(void)hideUserInfoViewController{
    if(_userInfoViewController!=nil){
        [_userInfoViewController hideUserInfoControllerView];
        _userInfoViewController=nil;
    }
}

#pragma mark - 实现ArticleInfoDelegate协议
-(void)pictureTappedWithArticle:(ArticleInfo *)article Index:(NSUInteger)index{
    _photoBrowser=[[MWPhotoBrowser alloc]initWithDelegate:self];
    _photoBrowser.displayActionButton=NO;
    
    _photoBrowserPhotos=[[NSMutableArray alloc]initWithCapacity:article.pictures.count];
    for(int i=0;i<article.pictures.count;i++){
        PictureInfo *picture=article.pictures[i];
        NSURL *url=nil;
        if(picture.isFromBBS){
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@?oauth_token=%@",picture.original_url,[LoginManager sharedManager].access_token]];
        }
        else{
            url=[NSURL URLWithString:
                 [NSString stringWithFormat:@"%@",picture.original_url]];
        }
        
        [_photoBrowserPhotos addObject:[MWPhoto photoWithURL:url]];
    }
    [_photoBrowser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:_photoBrowser animated:YES];
}

-(void)updateTableView:(ArticleInfo *)article{
    NSArray * array=[self.tableView indexPathsForVisibleRows];
    for(int i=0;i<array.count;i++){
        if(_data[((NSIndexPath *)array[i]).row]==article){
            [self.tableView reloadRowAtIndexPath:(NSIndexPath *)array[i] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}


#pragma mark - 实现MWPhotoBrowserDelegate协议
-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return _photoBrowserPhotos.count;
}
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    return _photoBrowserPhotos[index];
}
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    return _photoBrowserPhotos[index];
}
@end
