//
//  LaunchViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/18.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserHttpResponseDelegate.h"

@interface LaunchViewController : UIViewController<UserHttpResponseDelegate>

+(LaunchViewController*)getInstanceWithUserId:(NSString*)userid
                                      FaceUrl:(NSString*)faceUrl
                         WhetherUserFirstLoad:(BOOL)firstLoad;

@end
