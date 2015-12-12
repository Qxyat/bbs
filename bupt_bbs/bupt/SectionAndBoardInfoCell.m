//
//  SectionAndBoardInfoCell.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SectionAndBoardInfoCell.h"

@implementation SectionAndBoardInfoCell

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 135)];
        self.imageView.image=[UIImage imageNamed:@"section_default"];
        self.label=[[UILabel alloc]initWithFrame:CGRectMake(0, 135, 90, 40)];
        self.label.textAlignment=NSTextAlignmentCenter;
        self.label.numberOfLines=0;
        self.label.adjustsFontSizeToFitWidth=YES;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.label];
        self.contentView.layer.borderWidth=1;
        self.contentView.layer.borderColor=[UIColor blueColor].CGColor;
    }
    return self;
}

@end
