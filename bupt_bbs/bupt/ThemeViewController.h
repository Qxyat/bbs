//
//  ThemeViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeViewController : UITableViewController

+(instancetype)getInstanceWithBoardName:(NSString *)boardName
                            withGroupId:(int)groupId;
-(void)jumpToRefresh:(NSUInteger) nextPage;

@end
