//
//  UserMainInterfaceViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/2/29.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "UserMainInterfaceViewController.h"
#import "TopSectionViewController.h"
#import "TopTenViewController.h"
#import "RecommedArticalViewController.h"
#import "BoardViewController.h"

@interface UserMainInterfaceViewController ()

@end

@implementation UserMainInterfaceViewController

+(instancetype)getInstance{
    return [[UserMainInterfaceViewController alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initTabbarItem];
}

#pragma mark - 初始化TabbarItem
-(void)_initTabbarItem{
    NSMutableArray *items=[[NSMutableArray alloc]initWithCapacity:3];
    {
        TopSectionViewController *topSectionViewController=[TopSectionViewController getInstance];
        UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:topSectionViewController];
        navigationController.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"讨论区" image:nil selectedImage:nil];
        [items addObject:navigationController];
    }
    {
        TopTenViewController *topTenViewController=[TopTenViewController getInstance];
        UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:topTenViewController];
        navigationController.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"十大热门" image:nil selectedImage:nil];
        [items addObject:navigationController];
    }
    {
        RecommedArticalViewController *recommendArticalViewController=[RecommedArticalViewController getInstance];
        UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:recommendArticalViewController];
        navigationController.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"推荐文章" image:nil selectedImage:nil];
        [items addObject:navigationController];
    }
    {
        BoardViewController *boardViewController=[BoardViewController getInstanceWithBoardName:@"Job" withBoardDescription:@"毕业生找工作" withCouldBack:NO];
        UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:boardViewController];
        navigationController.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"毕业生找工作" image:nil selectedImage:nil];
        [items addObject:navigationController];
    }
    {
        BoardViewController *boardViewController=[BoardViewController getInstanceWithBoardName:@"ParttimeJob" withBoardDescription:@"兼职实习信息" withCouldBack:NO];
        UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:boardViewController];
        navigationController.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"兼职实习信息" image:nil selectedImage:nil];
        [items addObject:navigationController];
    }
    self.viewControllers=items;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
