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
    return [[ThemePopoverController alloc]initWithNibName:@"ThemePopoverController" bundle:nil];
}
-(void)loadView{
    [super loadView];
    self.view.bounds=kCustomScreenBounds;
    [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[[UIColor alloc]initWithWhite:0 alpha:0];
    
    UITapGestureRecognizer *recognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showJumpView)];
    UITapGestureRecognizer *recognizer2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showJumpView)];
    [self.jumpImageView addGestureRecognizer:recognizer1];
    [self.jumpLabel addGestureRecognizer:recognizer2];
    UITapGestureRecognizer *recognizer3=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideThemePopoverController)];
    [self.view addGestureRecognizer:recognizer3];
   
    self.view.center=CGPointMake(kCustomScreenWidth/2, kCustomScreenHeight/2-self.containerView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center=CGPointMake(kCustomScreenWidth/2, kCustomScreenHeight/2);
    }];
}
-(void)hideThemePopoverController{
    [self.delegate hideThemePopoverController];
}
-(void)hideThemePopoverControllerView{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center=CGPointMake(kCustomScreenWidth/2,kCustomScreenHeight/2-self.containerView.frame.size.height);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showJumpView{
    
}

@end
