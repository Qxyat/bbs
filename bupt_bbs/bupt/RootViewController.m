//
//  RootViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "RootViewController.h"
#import "UserCenterViewController.h"
#import "LoginManager.h"
#import "ScreenAdaptionUtilities.h"
#import "UserMainInterfaceViewController.h"
#import "ReplyViewController.h"

#import <UIImageView+WebCache.h>

static CGFloat const kProportion=0.77;

@interface RootViewController()
@property (nonatomic) CGFloat moveDistance;
@property (nonatomic) CGFloat maxMoveDistance;

@property (strong,nonatomic) UserCenterViewController *userViewController;
@property (strong,nonatomic) UserMainInterfaceViewController *userMainInterfaceViewController;
@property (strong,nonatomic) UIView *blackCover;

@property (strong,nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation RootViewController
+(instancetype)getInstance{
    RootViewController *controller=[[RootViewController alloc]init];
    return controller;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.moveDistance=0;
    self.maxMoveDistance=(kProportion+kProportion/2-0.5)*kCustomScreenWidth;
    
    UIImage *image=[UIImage imageNamed:@"bg-root"];
    UIGraphicsBeginImageContext(kCustomScreenSize);
    [image drawInRect:kCustomScreenBounds];
    image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor=[UIColor colorWithPatternImage:image];
    
    self.userViewController=[UserCenterViewController getInstance];
    self.userViewController.view.center=CGPointMake(kCustomScreenWidth*kProportion/2, self.userViewController.view.center.y);
    self.userViewController.view.transform=CGAffineTransformMakeScale(kProportion, kProportion);
    [self.view addSubview:self.userViewController.view];
    
    self.blackCover=[[UIView alloc]initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
    self.blackCover.backgroundColor=[UIColor blackColor];
    [self.view addSubview:self.blackCover];
    
    self.userMainInterfaceViewController=[UserMainInterfaceViewController getInstance];
    self.userMainInterfaceViewController.selectedIndex=1;
    
    [self.view addSubview:self.userMainInterfaceViewController.view];
    
    UIPanGestureRecognizer *panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureEvent:)];
//    panGestureRecognizer.delegate=self;
    [self.userMainInterfaceViewController.view addGestureRecognizer:panGestureRecognizer];
    self.tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMain)];
    self.tapGestureRecognizer.enabled=NO;
    [self.userMainInterfaceViewController.view addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark -
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}
#pragma mark - 实现UIGestureRecognizerDelegate
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    
//    for(int i=0;i<_userMainInterfaceViewController.navigationControllers.count;i++){
//        UINavigationController *navicontroller=_userMainInterfaceViewController.navigationControllers[i];
//        if([navicontroller.topViewController isKindOfClass:[ReplyViewController class]])
//            return NO;
//    }
//    return YES;
//}
#pragma mark - 手势动作
-(void)panGestureEvent:(UIPanGestureRecognizer*)recognizer{
    CGFloat x=[recognizer translationInView:self.view].x;
    x=x/12;
    self.moveDistance=self.moveDistance+x;
    CGFloat mainProportion=0;
    CGFloat homeProportation=0;
    if(recognizer.state==UIGestureRecognizerStateEnded){
        if(self.moveDistance>kCustomScreenWidth*kProportion/3){
            [self showLeft];
        }
        else
            [self showMain];
        return;
    }
    
    if(self.moveDistance>0){
        if(self.moveDistance>self.maxMoveDistance){
            self.moveDistance=self.maxMoveDistance;
            mainProportion=kProportion;
        }
        else{
            mainProportion=self.moveDistance/self.maxMoveDistance;
            mainProportion*=(kProportion-1);
            mainProportion+=1;
        }
    }
    else{
        self.moveDistance=0;
        mainProportion=1;
    }
    
    homeProportation=kProportion+1-mainProportion;
    self.userViewController.view.center=CGPointMake(kCustomScreenWidth*homeProportation/2, self.userViewController.view.center.y);
    self.userViewController.view.transform=CGAffineTransformMakeScale(homeProportation, homeProportation);
    self.blackCover.alpha=(mainProportion-kProportion)/(1-kProportion);
    
    recognizer.view.center=CGPointMake(self.view.center.x+self.moveDistance, self.view.center.y);
    recognizer.view.transform=CGAffineTransformMakeScale(mainProportion, mainProportion);
}

-(void)showLeft{
    self.moveDistance=self.maxMoveDistance;
    self.tapGestureRecognizer.enabled=YES;
    [self doTheAnimation:kProportion];
}
-(void)showMain{
    self.moveDistance=0;
    self.tapGestureRecognizer.enabled=NO;
    [self doTheAnimation:1];
}
-(void)doTheAnimation:(CGFloat)proportion{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat homeProportation=kProportion+1-proportion;
        self.userViewController.view.center=CGPointMake(kCustomScreenWidth*homeProportation/2, self.userViewController.view.center.y);
        self.userViewController.view.transform=CGAffineTransformMakeScale(homeProportation, homeProportation);
        
        self.blackCover.alpha=(proportion-kProportion)/(1-kProportion);
        
        self.userMainInterfaceViewController.view.center=CGPointMake(self.view.center.x+self.moveDistance, self.view.center.y);
        self.userMainInterfaceViewController.view.transform=CGAffineTransformMakeScale(proportion,proportion);
    } completion:nil];
}
@end
