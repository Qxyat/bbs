//
//  ThemeViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/3.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpResponseDelegate.h"
#import "ThemePopoverControllerDelegate.h"
#import "JumpPopoverControllerDelegate.h"
#import "RefreshTableViewDelegate.h"
@interface ThemeViewController : UITableViewController<HttpResponseDelegate,ThemePopoverControllerDelegate,JumpPopoverControllerDelegate,RefreshTableViewDelegate>

+(instancetype)getInstanceWithBoardName:(NSString *)boardName
                            withGroupId:(int)groupId;
-(void)jumpToRefresh:(NSUInteger) nextPage;
@end
