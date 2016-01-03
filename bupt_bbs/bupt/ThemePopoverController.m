//
//  ThemePopoverController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/3.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "ThemePopoverController.h"
#import "ScreenAdaptionUtilities.h"
@interface ThemePopoverController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *jumpImageView;
@property (weak, nonatomic) IBOutlet UILabel *jumpLabel;

@end

@implementation ThemePopoverController

+(instancetype)getInstance{
    return [[ThemePopoverController alloc]initWithNibName:@"ThemePopoverControllerView" bundle:nil];
}
-(void)loadView{
    [super loadView];
    CGFloat y=self.navigationBarHeight+kCustomStatusBarHeight;
    self.view.frame=CGRectMake(0, y,kCustomScreenWidth, kCustomScreenHeight-y);
    [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *recognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showJumpPopoverController)];
    UITapGestureRecognizer *recognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showJumpPopoverController)];
    [self.jumpImageView addGestureRecognizer:recognizer1];
    [self.jumpLabel addGestureRecognizer:recognizer2];
    UITapGestureRecognizer *recognizer3=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideThemePopoverController)];
    [self.view addGestureRecognizer:recognizer3];
   
    self.containerView.center=CGPointMake(self.containerView.center.x, self.containerView.center.y-self.containerView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.containerView.center=CGPointMake(self.containerView.center.x, self.containerView.center.y+self.containerView.frame.size.height);
    }];
}
-(void)hideThemePopoverController{
    [self.delegate hideThemePopoverController];
}
-(void)hideThemePopoverControllerView{
    [UIView animateWithDuration:0.5 animations:^{
        self.containerView.center=CGPointMake(self.containerView.center.x, self.containerView.center.y-self.containerView.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showJumpPopoverController{
    [self.delegate showJumpPopoverController];
}

@end
