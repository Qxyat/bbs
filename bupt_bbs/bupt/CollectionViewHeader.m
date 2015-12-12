//
//  CollectionViewHeaderCollectionViewCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "CollectionViewHeader.h"

@implementation CollectionViewHeader

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.headerLabel=[[UILabel alloc]initWithFrame:CGRectOffset(self.contentView.bounds, 10, 0)];
        
        self.headerLabel.textAlignment=NSTextAlignmentLeft;
        [self.contentView addSubview:self.headerLabel];
    }
    return self;
}
@end
