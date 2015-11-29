//
//  HomeViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/29.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "HomeViewController.h"
static CGFloat const kProportion=0.77;

@interface RootViewController()
@property (nonatomic) CGFloat moveDistance;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat maxMoveDistance;
@property (nonatomic) UIView *blackCover;
@property (strong,nonatomic) HomeViewController *homeViewController;
@property (strong,nonatomic) MainViewController *mainViewController;
@end

@implementation RootViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.moveDistance=0;
    self.screenWidth=[UIScreen mainScreen].bounds.size.width;
    self.maxMoveDistance=(kProportion+kProportion/2-0.5)*self.screenWidth;
    
    self.view.backgroundColor=[UIColor greenColor];
    
    self.homeViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    self.homeViewController.view.center=CGPointMake(self.screenWidth*kProportion/2, self.homeViewController.view.center.y);
    self.homeViewController.view.transform=CGAffineTransformMakeScale(kProportion, kProportion);
    
    [self.view addSubview:self.homeViewController.view];
    
    self.blackCover=[[UIView alloc]initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
    self.blackCover.backgroundColor=[UIColor blackColor];
    [self.view addSubview:self.blackCover];
    
    self.mainViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
    
    [self.view addSubview:self.mainViewController.view];
    
    UIPanGestureRecognizer *panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureEvent:)];
    [self.mainViewController.view addGestureRecognizer:panGestureRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMain)];
    [self.mainViewController.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)panGestureEvent:(UIPanGestureRecognizer*)recognizer{
    CGFloat x=[recognizer translationInView:self.view].x;
    x=x/20;
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
    self.homeViewController.view.center=CGPointMake(self.screenWidth*homeProportation/2, self.homeViewController.view.center.y);
    self.homeViewController.view.transform=CGAffineTransformMakeScale(homeProportation, homeProportation);
    self.blackCover.alpha=(mainProportion-kProportion)/(1-kProportion);
    
    recognizer.view.center=CGPointMake(self.view.center.x+self.moveDistance, self.view.center.y);
    recognizer.view.transform=CGAffineTransformMakeScale(mainProportion, mainProportion);
}
-(void)showLeft{
    self.moveDistance=(kProportion+kProportion/2-0.5)*self.screenWidth;
    [self doTheAnimation:kProportion];
}
-(void)showMain{
    self.moveDistance=0;
    [self doTheAnimation:1];
}
-(void)doTheAnimation:(CGFloat)proportion{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat homeProportation=kProportion+1-proportion;
        self.homeViewController.view.center=CGPointMake(self.screenWidth*homeProportation/2, self.homeViewController.view.center.y);
        self.homeViewController.view.transform=CGAffineTransformMakeScale(homeProportation, homeProportation);
        
        self.blackCover.alpha=(proportion-kProportion)/(1-kProportion);
        
        self.mainViewController.view.center=CGPointMake(self.view.center.x+self.moveDistance, self.view.center.y);
        self.mainViewController.view.transform=CGAffineTransformMakeScale(proportion,proportion);
    } completion:nil];
}
@end
