//
//  MailboxViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/20.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailboxViewController.h"
#import "ScreenAdaptionUtilities.h"
#import "MailboxSelectPopoverController.h"
#import "MailboxUtilities.h"
#import "HttpResponseDelegate.h"
#import "MailInfo.h"
#import "CustomUtilities.h"
#import "MailInfoCell.h"
#import "MailReadViewController.h"
#import "CustomPopoverController.h"
#import "JumpPopoverController.h"
#import "MailPostViewController.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import <SVProgressHUD.h>

static NSString *const kCellIdentifier=@"cell";

@interface MailboxViewController ()<MailboxSelectPopoverControllerDelegate,HttpResponseDelegate,CustomPopoverControllerDelegate,JumpPopoverControllerDelegate>

@property (strong,nonatomic)MailboxSelectPopoverController *mailboxSelectPopoverController;
@property (strong,nonatomic)CustomPopoverController *customPopoverController;
@property (strong,nonatomic)JumpPopoverController *jumpPopoverController;

@property (strong,nonatomic)UIButton *titleview;
@property (strong,nonatomic)NSString* selectedMailbox;

@property (nonatomic)       NSInteger page_all_count;
@property (nonatomic)       NSInteger page_cur_count;
@property (nonatomic)       NSInteger item_page_count;

@property (nonatomic,strong)  NSArray   *data;

@end

@implementation MailboxViewController
+(instancetype)getInstance{
    return [[MailboxViewController alloc]init];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    _selectedMailbox=@"inbox";
    _page_cur_count=1;
    _page_all_count=1;
    _item_page_count=20;
    _data=[[NSArray alloc]init];
    
    [self _initNavigationItem];
    [self _initTableview];
   
    [self _refreshMailList];
}


#pragma mark - 初始化各个控件
-(void)_initNavigationItem{
    UIBarButtonItem *leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_cancle)];
    self.navigationItem.leftBarButtonItem=leftBarButtonItem;
    
    _selectedMailbox=@"inbox";
    
    _titleview=[UIButton buttonWithType:UIButtonTypeCustom];
    [_titleview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_titleview setTitle:@"收件箱" forState:UIControlStateNormal];
    [_titleview addTarget:self action:@selector(showMailboxSelectPopoverController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView=_titleview;
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kCustomNavigationBarHeight-8, kCustomNavigationBarHeight-8)];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.image=[UIImage imageNamed:@"more"];
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCustomPopoverController)];
    [imageView addGestureRecognizer:recognizer];
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem=barButtonItem;
}
-(void)_initTableview{
    [self.tableView registerNib:[UINib nibWithNibName:@"MailInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
}


#pragma mark - 点击更多按钮
-(void)showCustomPopoverController{
    [self hideJumpPopoverController];
    if(_customPopoverController==nil){
        CGFloat yOffset=CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGRect frame=CGRectMake(0, yOffset, kCustomScreenWidth,kCustomScreenHeight-yOffset);
        NSArray *pictures=@[@{CustomPopoverControllerImageTypeNormal:@"btn_jump_n",CustomPopoverControllerImageTypeHighlighted: @"btn_jump_h"},@{CustomPopoverControllerImageTypeNormal:@"btn_writemail_n",CustomPopoverControllerImageTypeHighlighted:@"btn_writemail_h"}];
        _customPopoverController=[CustomPopoverController getInstanceWithFrame:frame withItemNames:@[@"跳页",@"写信"] withItemPictures:pictures withDelegate:self];
        [self.tableView.superview addSubview:_customPopoverController.view];
    }
    else{
        [self hideCustomPopoverController];
    }
}

#pragma mark - 实现UITableviewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MailInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.mailInfo=_data[indexPath.row];
    return cell;
}


#pragma mark - 实现UITableviewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:kCellIdentifier configuration:^(id cell) {
        MailInfoCell* prototypeCell=(MailInfoCell*)cell;
        prototypeCell.mailInfo=_data[indexPath.row];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MailInfo *mailinfo=_data[indexPath.row];
    MailReadViewController *controller=[MailReadViewController getInstanceWithMailBoxName:_selectedMailbox withIndex:mailinfo.index];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 取消按钮
-(void)_cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 显示选择信箱列表的控制器
-(void)showMailboxSelectPopoverController{
    if(_mailboxSelectPopoverController==nil){
        _mailboxSelectPopoverController=[MailboxSelectPopoverController getInstance];
        _mailboxSelectPopoverController.delegate=self;
        _mailboxSelectPopoverController.navigationBarHeight=kCustomNavigationBarHeight;
        [self.tableView.superview addSubview:_mailboxSelectPopoverController.view];
    }
    else{
        [self hideMailboxSelectPopoverController];
    }
}


#pragma  mark - 实现MailboxSelectPopoverControllerDelegate协议
-(void)hideMailboxSelectPopoverController{
    if(_mailboxSelectPopoverController!=nil){
        [_mailboxSelectPopoverController hideMailboxSelectView];
        _mailboxSelectPopoverController=nil;
    }
}

-(void)disSelectItemAtIndex:(NSInteger)pos{
    NSArray* selectItems=@[@"收件箱",@"发件箱",@"回收站"];
    NSArray* items=@[@"inbox",@"outbox",@"deleted"];
    
    _selectedMailbox=items[pos];
    
    [_titleview setTitle:selectItems[pos] forState:UIControlStateNormal];
    _page_cur_count=1;
    _page_all_count=1;
    
    [self _refreshMailList];
    [self hideMailboxSelectPopoverController];
}


#pragma mark - 刷新信箱内容
-(void)_refreshMailList{
    [MailboxUtilities getMailsWithMailbox:_selectedMailbox withPageNO:_page_cur_count withPagecount:_item_page_count withDelegate:self];
}


#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    NSDictionary *dic=(NSDictionary*)response;
    _page_all_count=[[[dic valueForKey:@"pagination"]valueForKey:@"page_all_count"]integerValue];
    _page_cur_count=[[[dic objectForKey:@"pagination"]valueForKey:@"page_current_count"] integerValue];
    _data=[MailInfo getMailsInfo:[dic objectForKey:@"mail"]];
    
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

}

#pragma mark - 实现CustomPopoverControllerDelegate协议
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
            _jumpPopoverController=[JumpPopoverController getInstanceWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), kCustomScreenWidth, kCustomScreenHeight-CGRectGetMaxY(self.navigationController.navigationBar.frame)) withPageAllCount:_page_all_count withPageCurCount:_page_cur_count withDelegate:self];
            [self.tableView.superview addSubview:_jumpPopoverController.view];
        }
        else{
            [self hideJumpPopoverController];
        }
    }
    else if(index==1){
        MailPostViewController* mailPostViewController=[MailPostViewController getInstanceWithIsReply:NO withBoxName:nil withReceiverId:nil withTitle:nil withContent:nil withIndex:0];
        [self.navigationController pushViewController:mailPostViewController animated:YES];
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
    _page_cur_count=nextPage;
    [self _refreshMailList];
}
@end
