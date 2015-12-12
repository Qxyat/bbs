//
//  SectionInfo.h
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionInfo : NSObject

@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *section_description;
@property(nonatomic)BOOL is_root;
@property(strong,nonatomic)NSString *parent;

+(NSMutableArray*)getSectionsInfo:(id)item;
+(SectionInfo*)getSectionInfo:(id)item;

@end
