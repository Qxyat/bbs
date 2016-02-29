//
//  RecommedArticalViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/1.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpResponseDelegate.h"

@interface RecommedArticalViewController : UITableViewController<HttpResponseDelegate>

+(instancetype)getInstance;

@end
