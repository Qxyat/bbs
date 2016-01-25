//
//  CustomPopoverController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/23.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>


#define CustomPopoverControllerImageTypeNormal @"normal"
#define CustomPopoverControllerImageTypeHighlighted @"highlighted"


@protocol CustomPopoverControllerDelegate <NSObject>

-(void)hideCustomPopoverController;
-(void)itemTapped:(NSInteger)index;

@end

@interface CustomPopoverController : UIViewController

+(instancetype)getInstanceWithFrame:(CGRect)frame
                      withItemNames:(NSArray*)itemNames
                   withItemPictures:(NSArray*)itemPictures
                       withDelegate:(id<CustomPopoverControllerDelegate>)delegate;

-(void)hideCustomPopoverControllerView;

@end
