//
//  ThemeViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpResponseDelegate.h"
#import "AttributedStringDelegate.h"
#import "ThemePopoverControllerDelegate.h"
#import "JumpPopoverControllerDelegate.h"
@interface ThemeViewController : UITableViewController<HttpResponseDelegate,AttributedStringDelegate,ThemePopoverControllerDelegate,JumpPopoverControllerDelegate>

@property (nonatomic) int group_id;
@property (strong,nonatomic) NSString *board_name;
@property (strong,nonatomic) NSString *theme_title;

-(void)jumpToRefresh:(NSUInteger) nextPage;
@end
