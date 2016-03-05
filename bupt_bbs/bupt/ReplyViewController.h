//
//  ReplyViewController.h
//  bupt
//
//  Created by 邱鑫玥 on 16/1/9.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit.h>
#import "HttpResponseDelegate.h"
#import "QCEmojiKeyboardDelegate.h"
#import "AttachmentHttpResponseDelegate.h"
#import "ReplyViewImageCellDelegate.h"

@class ArticleInfo;

@interface ReplyViewController : UIViewController<HttpResponseDelegate,QCEmojiKeyboardDelegate,YYTextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AttachmentHttpResponseDelegate,ReplyViewImageCellDelegate>

+(instancetype)getInstanceWithBoardName:(NSString*)boardName
                             isNewTheme:(BOOL)isNewTheme
                        withArticleName:(NSString*)
                                          articleName
                          withArticleId:(int)articleId
                        withArticleInfo:(ArticleInfo*)
                                          articleInfo;
@end
