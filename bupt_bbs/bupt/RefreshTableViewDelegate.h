//
//  RefreshTableViewDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RefreshTableViewDelegate <NSObject>
-(void)refreshTableView:(NSString*)url;
@end
