//
//  MailReadViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/22.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailReadViewController : UIViewController

+(instancetype)getInstanceWithMailBoxName:(NSString*)box_name
                                withIndex:(NSInteger)index;

@end
