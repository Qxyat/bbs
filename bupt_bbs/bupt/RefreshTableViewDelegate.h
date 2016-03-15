//
//  RefreshTableViewDelegate.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/5.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ArticleInfo;
@protocol RefreshTableViewDelegate <NSObject>
-(void)refreshTableView:(ArticleInfo*)article;
@end
