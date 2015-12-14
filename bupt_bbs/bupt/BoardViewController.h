//
//  BoardViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/13.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpResponseDelegate.h"

@interface BoardViewController : UITableViewController<HttpResponseDelegate>

@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *board_description;

@end
