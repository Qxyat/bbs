//
//  MailboxSelectPopoverController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/21.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "MailboxSelectPopoverController.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"

#import <Masonry.h>

#define kSelectItemHeight 40
#define kContainerViewWith 70
#define kContainerViewHeight  3*kSelectItemHeight

@interface MailboxSelectPopoverController ()

@property (strong,nonatomic) UIView * containerView;

@end

@implementation MailboxSelectPopoverController

+(instancetype)getInstance{
    return [[MailboxSelectPopoverController alloc]init];
}
-(void)loadView{
    [super loadView];
    CGFloat y=self.navigationBarHeight+kCustomStatusBarHeight;
    self.view.frame=CGRectMake(0, y,kCustomScreenWidth, kCustomScreenHeight-y);
    
    _containerView=[[UIView alloc]init];
    _containerView.backgroundColor=[CustomUtilities getColor:@"F9F9F9"];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_top);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(kContainerViewHeight);
        make.width.mas_equalTo(kContainerViewWith);
    }];
    
    for(int i=0;i<3;i++){
        [self _createSelectItem:i];
    }
    
    [self.view layoutIfNeeded];
}


#pragma mark - 创建选择按钮
-(void)_createSelectItem:(NSInteger)pos{
    NSArray* selectItems=@[@"收件箱",@"发件箱",@"回收站"];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.tag=pos;
    [button setTitle:selectItems[pos] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    button.titleLabel.textAlignment=NSTextAlignmentCenter;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_containerView.mas_top).with.offset(pos*kSelectItemHeight);
        make.centerX.equalTo(_containerView.mas_centerX);
        make.width.mas_equalTo(kContainerViewWith);
        make.height.mas_equalTo(kSelectItemHeight);
    }];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_top).with.offset(kContainerViewHeight);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMailboxSelectPopoverController)];
    [self.view addGestureRecognizer:gesture];
    
}

-(void)hideMailboxSelectPopoverController{
    [_delegate hideMailboxSelectPopoverController];
}

-(void)hideMailboxSelectView{
    [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_top);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}
-(void)buttonPressed:(UIButton *)sender{
    [_delegate disSelectItemAtIndex:sender.tag];
}
@end
