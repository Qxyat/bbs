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



+(instancetype)getInstanceWithBoardName:(NSString *)name
                   withBoardDescription:(NSString *)board_description
                          withCouldBack:(BOOL)couldBack;

@end
