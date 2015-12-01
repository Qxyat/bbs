//
//  userViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "RootViewController.h"
#import "UserViewController.h"
static CGFloat const kProportion=0.77;

@interface RootViewController()
@property (nonatomic) CGFloat moveDistance;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat maxMoveDistance;

@property (strong,nonatomic) UIView *blackCover;
@property (strong,nonatomic) UserViewController *userViewController;
@property (strong,nonatomic) UITabBarController *userMainInterfaceViewController;
@property (strong,nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation RootViewController
-(void)viewDidLoad{
    [super viewDidLoad];

    self.moveDistance=0;
    self.screenWidth=[UIScreen mainScreen].bounds.size.width;
    self.maxMoveDistance=(kProportion+kProportion/2-0.5)*self.screenWidth;
    
    self.view.backgroundColor=[UIColor greenColor];
    
    self.userViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"userviewcontroller"];
    self.userViewController.view.center=CGPointMake(self.screenWidth*kProportion/2, self.userViewController.view.center.y);
    self.userViewController.view.transform=CGAffineTransformMakeScale(kProportion, kProportion);
    
    [self.view addSubview:self.userViewController.view];
    
    self.blackCover=[[UIView alloc]initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
    self.blackCover.backgroundColor=[UIColor blackColor];
    [self.view addSubview:self.blackCover];
    
    [self getuserMainInterfaceViewController];
    [self.view addSubview:self.userMainInterfaceViewController.view];
    
    UIPanGestureRecognizer *panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureEvent:)];
    [self.userMainInterfaceViewController.view addGestureRecognizer:panGestureRecognizer];
    self.tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMain)];
    self.tapGestureRecognizer.enabled=NO;
    [self.userMainInterfaceViewController.view addGestureRecognizer:self.tapGestureRecognizer];
}

-(void)getuserMainInterfaceViewController{
    UIStoryboard *strotyboard=[UIStoryboard storyboardWithName:@"UserMainInterface" bundle:nil];
    self.userMainInterfaceViewController=[strotyboard instantiateViewControllerWithIdentifier:@"userinterface"];
    self.userMainInterfaceViewController.selectedIndex=1;
}

#pragma mark -
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}

#pragma mark - 手势动作
-(void)panGestureEvent:(UIPanGestureRecognizer*)recognizer{
    CGFloat x=[recognizer translationInView:self.view].x;
    x=x/12;
    self.moveDistance=self.moveDistance+x;
    CGFloat mainProportion=0;
    CGFloat homeProportation=0;
    if(recognizer.state==UIGestureRecognizerStateEnded){
        if(self.moveDistance>self.screenWidth*kProportion/3){
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
    self.userViewController.view.center=CGPointMake(self.screenWidth*homeProportation/2, self.userViewController.view.center.y);
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
        self.userViewController.view.center=CGPointMake(self.screenWidth*homeProportation/2, self.userViewController.view.center.y);
        self.userViewController.view.transform=CGAffineTransformMakeScale(homeProportation, homeProportation);
        
        self.blackCover.alpha=(proportion-kProportion)/(1-kProportion);
        
        self.userMainInterfaceViewController.view.center=CGPointMake(self.view.center.x+self.moveDistance, self.view.center.y);
        self.userMainInterfaceViewController.view.transform=CGAffineTransformMakeScale(proportion,proportion);
    } completion:nil];
}
@end