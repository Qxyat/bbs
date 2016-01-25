//
//  CustomPopoverController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/23.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "CustomPopoverController.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomUtilities.h"
#import <Masonry.h>

#define kItemContainerViewHeight 66
#define kMargin            8
#define kItemPictureHeight 30
#define kItemNameHeight 20
#define kItemFontSize 16

static CGFloat kItemContainerViewWidth;

@interface CustomPopoverController ()

@property (nonatomic)CGRect frame;

@property (copy,nonatomic)NSArray *itemNames;
@property (copy,nonatomic)NSArray *itempictures;
@property (strong,nonatomic)NSMutableArray *itemContainerViews;

@property (weak,nonatomic)id<CustomPopoverControllerDelegate>delegate;

@property (strong,nonatomic)UIView *containerView;

@end

@implementation CustomPopoverController

+(instancetype)getInstanceWithFrame:(CGRect)frame
                          withItemNames:(NSArray*)itemNames
                   withItemPictures:(NSArray*)itemPictures
                       withDelegate:(id<CustomPopoverControllerDelegate>)delegate;
{
    CustomPopoverController *controller=[[CustomPopoverController alloc]init];
    controller.frame=frame;
    controller.itemNames=itemNames;
    controller.itempictures=itemPictures;
    controller.delegate=delegate;
    if(itemNames!=nil)
        kItemContainerViewWidth=kCustomScreenWidth/itemNames.count;
    else
        kItemContainerViewWidth=kCustomScreenWidth/itemPictures.count;
    
    return  controller;
}
-(void)loadView{
    [super loadView];
    self.view.frame=_frame;
    self.view.backgroundColor=[UIColor clearColor];
    
    _containerView=[[UIView alloc]init];
    _containerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_containerView];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_top);
    }];
    
    for(int i=0;i<_itemNames.count;i++)
        [self _loadItemViewWithIndex:i];
    
    [self.view layoutIfNeeded];
}

-(void)_loadItemViewWithIndex:(NSInteger)index{
    UIView *itemContainerView=[[UIView alloc]init];
    
    [_containerView addSubview:itemContainerView];
    
    [itemContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_leading).with.offset(kItemContainerViewWidth*index);
        make.top.equalTo(_containerView.mas_top);
        make.bottom.equalTo(_containerView.mas_bottom);
        make.height.mas_equalTo(kItemContainerViewHeight);
        make.width.mas_equalTo(kItemContainerViewWidth);
    }];
    
    if(_itempictures!=nil){
        UIButton *picbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        [picbutton setBackgroundImage:[UIImage imageNamed:_itempictures[index][CustomPopoverControllerImageTypeNormal]] forState:UIControlStateNormal];
        [picbutton setBackgroundImage:[UIImage imageNamed:_itempictures[index][CustomPopoverControllerImageTypeHighlighted]] forState:UIControlStateHighlighted];
        picbutton.tag=index;
        [picbutton addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
        [itemContainerView addSubview:picbutton];
        [picbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(itemContainerView.mas_top).with.offset(kMargin);
            make.width.mas_equalTo(kItemPictureHeight);
            make.height.mas_equalTo(kItemPictureHeight);
            make.centerX.equalTo(itemContainerView.mas_centerX);
        }];
        
        UIButton *labelbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        [labelbutton setTitle:_itemNames[index] forState:UIControlStateNormal];
        labelbutton.titleLabel.font=[UIFont systemFontOfSize:kItemFontSize];
        labelbutton.titleLabel.minimumScaleFactor=0.5;
        [labelbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [labelbutton setTitleColor:[CustomUtilities getColor:@"007aff"] forState:UIControlStateHighlighted];
        labelbutton.tag=index;
        [labelbutton addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
        [itemContainerView addSubview:labelbutton];
        [labelbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(picbutton.mas_bottom).with.offset(kMargin);
            make.height.mas_equalTo(kItemNameHeight);
            make.centerX.equalTo(itemContainerView.mas_centerX);
        }];
    }
    else{
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:_itemNames[index] forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont systemFontOfSize:kItemFontSize];
        button.titleLabel.minimumScaleFactor=0.5;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[CustomUtilities getColor:@"007aff"] forState:UIControlStateHighlighted];
        button.tag=index;
        [button addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [itemContainerView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(itemContainerView.mas_centerY);
            make.height.mas_equalTo(kItemNameHeight);
            make.centerX.equalTo(itemContainerView.mas_centerX);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_top).with.offset(CGRectGetHeight(_containerView.frame));
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
    
    
    UITapGestureRecognizer *recognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideCustomPopoverController)];
    [self.view addGestureRecognizer:recognizer1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 点击Item
-(void)itemTapped:(UIButton *)button{
    if(_delegate!=nil){
        [_delegate itemTapped:button.tag];
    }
}

#pragma mark -隐藏CustomPopoverController
-(void)hideCustomPopoverController{
    if(_delegate!=nil){
        [_delegate hideCustomPopoverController];
    }
}
-(void)hideCustomPopoverControllerView{
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

@end
