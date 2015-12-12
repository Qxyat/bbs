//
//  SectionInfo.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/12.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SectionInfo.h"

static NSString * const kName=@"name";
static NSString * const kNameDescription=@"description";
static NSString * const kIsRoot=@"is_root";
static NSString * const kParent=@"parent";

@implementation SectionInfo

#pragma mark - 得到根分区下面的分区信息
+(NSMutableArray*)getSectionsInfo:(id)item{
    NSMutableArray *data=nil;
    
    if(item!=[NSNull null]){
        NSArray *array=(NSArray*)item;
        data=[[NSMutableArray alloc]initWithCapacity:array.count];
        for(int i=0;i<array.count;i++){
            [data addObject:[SectionInfo getSectionInfo:array[i]]];
        }
    }
    
    return  data;
}

#pragma mark - 得到一个分区的信息
+(SectionInfo*)getSectionInfo:(id)item{
    SectionInfo * sectionInfo=[[SectionInfo alloc]init];
    NSDictionary *dic=(NSDictionary*)item;
    
    sectionInfo.name=[dic objectForKey:kName];
    sectionInfo.section_description=[dic objectForKey:kNameDescription];
    sectionInfo.is_root=[[dic objectForKey:kIsRoot]boolValue];
    sectionInfo.parent=[dic objectForKey:kParent];
    
    return  sectionInfo;
}

@end
