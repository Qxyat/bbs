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
#import <WYPopoverController.h>

@interface ThemeViewController : UITableViewController<HttpResponseDelegate,AttributedStringDelegate,WYPopoverControllerDelegate>

@property (nonatomic) int group_id;
@property (strong,nonatomic) NSString *board_name;
@property (strong,nonatomic) NSString *theme_title;
@property (strong,nonatomic)WYPopoverController *wyPopoverController;

-(void)jumpToRefresh:(NSUInteger) nextPage;
@end
