//
//  BoardViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpResponseDelegate.h"

@interface SectionViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout,HttpResponseDelegate>


@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *section_description;
@end
