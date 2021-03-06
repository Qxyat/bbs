//
//  AppDelegate.m
//  bupt
//
//  Created by 邱鑫玥 on 15/11/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginManager.h"
#import "FirstLoginViewController.h"
#import "SecondLoginViewController.h"
#import "RootViewController.h"
#import "LaunchViewController.h"
#import "UserInfo.h"
#import <SVProgressHUD.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //判断用户之前是否登陆过
    LoginManager * manager=[LoginManager sharedManager];
    if(manager.access_token==nil){
        if(manager.loginUserHistory.count>0){
            SecondLoginViewController *secondLoginViewController=[SecondLoginViewController getInstance];
            UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:secondLoginViewController];
            navigationController.navigationBar.hidden=YES;
            self.window.rootViewController=navigationController;
        }
        else{
            FirstLoginViewController *firstLoginViewController=[FirstLoginViewController getInstance:NO];
            UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:firstLoginViewController];
            navigationController.navigationBar.hidden=YES;
            self.window.rootViewController=navigationController;
        }
    }
    else{
        UserInfo *lastUserInfo=manager.loginUserHistory[0];
        LaunchViewController *launchViewController=[LaunchViewController getInstanceWithUserId:lastUserInfo.userId FaceUrl:lastUserInfo.face_url WhetherUserFirstLoad:NO];
        self.window.rootViewController=launchViewController;
    }
  
    [self.window makeKeyAndVisible];
    
    //全局样式的统一
    [SVProgressHUD setBackgroundColor:[[UIColor grayColor]colorWithAlphaComponent:0.5]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav_back_n"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav_back_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    //将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    
//    UITabBar *tabbar=[UITabBar appearance];
//    [tabbar setBarTintColor:[UIColor greenColor]];
//    [tabbar setTintColor:[UIColor whiteColor]];
//    
//    UINavigationBar *navigationBar=[UINavigationBar appearance];
//    [navigationBar setBarTintColor:[UIColor colorWithRed:48/255.f green:48/255.f blue:48/255.f alpha:48/255.f]];
//    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end


