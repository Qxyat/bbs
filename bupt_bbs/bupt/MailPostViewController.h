//
//  MailPostViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/25.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailPostViewController : UIViewController

+(instancetype)getInstanceWithIsReply:(BOOL)isReply
                          withBoxName:(NSString *)box_name
                       withReceiverId:(NSString *)userId
                            withTitle:(NSString *)mailTitle
                          withContent:(NSString *)content
                            withIndex:(NSInteger)index;
@end
