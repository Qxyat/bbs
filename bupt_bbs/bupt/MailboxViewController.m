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

@interface MailboxViewController ()<MailboxSelectPopoverControllerDelegate>

@property (strong,nonatomic)MailboxSelectPopoverController *mailboxSelectPopoverController;
@property (strong,nonatomic)UIButton *titleview;
@property (nonatomic)NSString* selectedMailbox;

@end

@implementation MailboxViewController
+(instancetype)getInstance{
    return [[MailboxViewController alloc]init];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self _initNavigationItem];
    [self _initTableview];
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
}
-(void)_initTableview{
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}
#pragma mark - 实现UITableviewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text=@"hello";
    return cell;
}
#pragma mark - 取消按钮
-(void)_cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 显示信箱列表
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
    
    NSLog(@"%@",_selectedMailbox);
    [_titleview setTitle:selectItems[pos] forState:UIControlStateNormal];
    
    [self hideMailboxSelectPopoverController];
}

@end
