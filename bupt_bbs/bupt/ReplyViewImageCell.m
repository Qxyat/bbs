//
//  ReplyViewImageCell.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/17.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "ReplyViewImageCell.h"

@interface ReplyViewImageCell ()

@property (strong,nonatomic)UIImageView *imageview;

@end

@implementation ReplyViewImageCell

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        _imageview=[[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _imageview.backgroundColor=[UIColor redColor];
        [self.contentView addSubview:_imageview];
    }
    return self;
}
-(void)setImage:(UIImage *)image{
    _image=image;
    _imageview.image=image;
}
@end
