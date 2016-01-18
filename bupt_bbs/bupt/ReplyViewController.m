//
//  ReplyViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 16/1/9.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "ReplyViewController.h"
#import "ArticleInfo.h"
#import "UserInfo.h"
#import "PostArticleUtilities.h"
#import "CustomUtilities.h"
#import "ScreenAdaptionUtilities.h"
#import "CustomEmojiKeyboard.h"
#import "YYImage+Emoji.h"
#import "CustomYYAnimatedImageView.h"
#import "AttachmentUtilities.h"
#import "ReplyViewImageCell.h"
#import "CustomLinePositionModifier.h"
#import <SVProgressHUD.h>
#import <Masonry.h>

#define kStatusBarHeight 20
#define kNavigationBarHeight 44
#define kTitleTextFiledHeight 36
#define kSeperatorViewHeight 1
#define kToolBarHeight 46+1
#define kToolBarItemHeight 46
#define kMargin 8
#define kImageSize (kCustomScreenWidth-4*kMargin)/3

@interface ReplyViewController ()

@property (strong,nonatomic)NSString *boardName;
@property (strong,nonatomic)NSString *articleName;
@property (nonatomic)BOOL isNewTheme;
@property (nonatomic)int articleId;
@property (strong,nonatomic)ArticleInfo *articleInfo;

@property (strong,nonatomic) UIScrollView *scrollview;
@property (strong,nonatomic) YYTextView *contentTextView;
@property (strong,nonatomic) UICollectionView *imagesContainer;

@property (strong,nonatomic) UITextField *titleTextField;
@property (strong,nonatomic) UIView *seperatorView;

@property (strong,nonatomic) UIView *toolbar;
@property (strong,nonatomic) UIButton *pictureButton;
@property (strong,nonatomic) UIButton *emojiButton;
@property (strong,nonatomic) UIView *dummyView;
@property (strong,nonatomic) CustomEmojiKeyboard *emojiKeyboard;

@property (strong,nonatomic) NSMutableArray *imageAttachments;
@end


@implementation ReplyViewController

+(instancetype)getInstanceWithBoardName:(NSString*)boardName
                             isNewTheme:(BOOL)isNewTheme
                        withArticleName:(NSString*)articleName
                          withArticleId:(int)articleId
                        withArticleInfo:(ArticleInfo*)articleInfo
{
    ReplyViewController *replyViewController=[[ReplyViewController alloc]init];
    
    replyViewController.boardName=boardName;
    replyViewController.articleName=articleName;
    replyViewController.isNewTheme=isNewTheme;
    replyViewController.articleId=articleId;
    replyViewController.articleInfo=articleInfo;
    
    return replyViewController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self _initScrollView];
    [self _initNavigationItem];
    [self _initTitleTextField];
    [self _initSeperatorView];
    [self _initToolbar];
    
    _emojiKeyboard=[[CustomEmojiKeyboard alloc]init];
    _emojiKeyboard.delegate=self;
    
    if(_isNewTheme){
        [_titleTextField becomeFirstResponder];
    }
    else{
        [_contentTextView becomeFirstResponder];
        _contentTextView.selectedRange=NSMakeRange(0, 0);
    }
    
    [_scrollview scrollToTop];
    _imageAttachments=[[NSMutableArray alloc]init];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 初始化各个view
-(void)_initScrollView{
    _scrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _scrollview.contentInset=UIEdgeInsetsMake(kTitleTextFiledHeight+kSeperatorViewHeight, 0, kToolBarHeight, 0);
    _scrollview.contentSize=CGSizeMake(CGRectGetWidth(self.view.frame), 0);
    _scrollview.showsHorizontalScrollIndicator=NO;
    _scrollview.showsVerticalScrollIndicator=NO;
    
    _contentTextView=[[YYTextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _scrollview.contentSize.height)];
    _contentTextView.showsVerticalScrollIndicator=NO;
    _contentTextView.allowsCopyAttributedString=NO;
    _contentTextView.textContainerInset=UIEdgeInsetsMake(12, kMargin, 12, kMargin);
    _contentTextView.font=[UIFont systemFontOfSize:17];
    _contentTextView.placeholderFont=[UIFont systemFontOfSize:17];
    _contentTextView.placeholderTextColor=[CustomUtilities getColor:@"B4B4B4"];
    _contentTextView.delegate=self;
    _contentTextView.scrollEnabled=NO;
    
    CustomLinePositionModifier *modifier = [CustomLinePositionModifier new];
    modifier.font = [UIFont systemFontOfSize:17];
    modifier.paddingTop = 12;
    modifier.paddingBottom = 12;
    modifier.lineHeightMultiple = 1.5;
    _contentTextView.linePositionModifier = modifier;
    
    if(!_isNewTheme){
        if(_articleInfo==nil){
            _contentTextView.placeholderText=@"在这里输入内容...";
        }
        else{
            NSRange range;
            range.location=0;
            if(_articleInfo.content.length>50){
                range.length=50;
            }
            else{
                range.length=_articleInfo.content.length;
            }
            NSMutableAttributedString *contenttext=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\n【在%@的大作中提到:】\n%@",_articleInfo.user.userId,[_articleInfo.content substringWithRange:range]]];
            contenttext.font=_contentTextView.font;
            _contentTextView.attributedText=contenttext;
        }
    }
    else{
        _contentTextView.placeholderText=@"在这里输入内容...";
    }
    
    [_scrollview addSubview:_contentTextView];
    
    UICollectionViewFlowLayout *flowlayout=[[UICollectionViewFlowLayout alloc]init];
    flowlayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    flowlayout.minimumInteritemSpacing=0;
    flowlayout.sectionInset=UIEdgeInsetsMake(0, 0, 0, 0);
    _imagesContainer=[[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_contentTextView.frame) ,CGRectGetWidth(self.view.frame) ,0) collectionViewLayout:flowlayout];
    _imagesContainer.contentInset=UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
    _imagesContainer.contentSize=CGSizeMake(CGRectGetWidth(self.view.frame)-2*kMargin, 0);
    _imagesContainer.showsVerticalScrollIndicator=NO;
    _imagesContainer.backgroundColor=[UIColor clearColor];
    _imagesContainer.dataSource=self;
    _imagesContainer.delegate=self;
    _imagesContainer.scrollEnabled=NO;
    [_imagesContainer registerClass:[ReplyViewImageCell class] forCellWithReuseIdentifier:@"cell"];

    [_scrollview addSubview:_imagesContainer];
    
    [self.view addSubview:_scrollview];
    
    [self _refreshScrollViewFrame];
}

-(void)_initNavigationItem{
    if(!_isNewTheme){
        self.navigationItem.title=@"回复";
    }
    else{
        self.navigationItem.title=@"新话题";
    }
    UIBarButtonItem *postBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(postArticle)];
    [postBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem=postBarButtonItem;
}

-(void)_initTitleTextField{
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+kStatusBarHeight, CGRectGetWidth(self.view.frame), kTitleTextFiledHeight)];
    bottomView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    _titleTextField=[[UITextField alloc]initWithFrame:CGRectMake(kMargin, kNavigationBarHeight+kStatusBarHeight, CGRectGetWidth(self.view.frame)-2*kMargin, kTitleTextFiledHeight)];
    _titleTextField.font=[UIFont systemFontOfSize:16];
    //为了防止下面的内容view 滚动时 覆盖掉title
    _titleTextField.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_titleTextField];
    
    if(!_isNewTheme){
        _titleTextField.text=[NSString stringWithFormat:@"Re:%@",_articleName];
    }
    else{
        _titleTextField.placeholder=@"在这里输入标题...";
    }
}

-(void)_initSeperatorView{
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight+kNavigationBarHeight+kTitleTextFiledHeight, CGRectGetWidth(self.view.frame), kSeperatorViewHeight)];
    bottomView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    _seperatorView=[[UIView alloc]initWithFrame:CGRectMake(kMargin, kStatusBarHeight+kNavigationBarHeight+kTitleTextFiledHeight, CGRectGetWidth(self.view.frame)-2*kMargin, kSeperatorViewHeight)];
    [self.view addSubview:_seperatorView];
    _seperatorView.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
}

-(void)_initToolbar{
    _toolbar=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-kToolBarHeight, CGRectGetWidth(self.view.frame), kToolBarHeight)];
     _toolbar.backgroundColor=[CustomUtilities getColor:@"F9F9F9"];
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolbar.frame), CGFloatFromPixel(1))];
    line.backgroundColor=[CustomUtilities getColor:@"BFBFBF"];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbar addSubview:line];
    
    _pictureButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _pictureButton.frame=CGRectMake(0, 0, kNavigationBarHeight, kNavigationBarHeight);
    _pictureButton.center=CGPointMake(CGRectGetWidth(_toolbar.frame)*0.25, CGRectGetHeight(_toolbar.frame)*0.5);
    [_pictureButton setImage:[UIImage imageNamed:@"toolbarpicture"] forState:UIControlStateNormal];
    [_pictureButton setImage:[UIImage imageNamed:@"toolbarpicturehighlighted"] forState:UIControlStateHighlighted];
    [_pictureButton addTarget:self action:@selector(choosePicture) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar addSubview:_pictureButton];
    
    _emojiButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _emojiButton.frame=CGRectMake(0, 0, kNavigationBarHeight, kNavigationBarHeight);
    _emojiButton.center=CGPointMake(CGRectGetWidth(_toolbar.frame)*0.75, CGRectGetHeight(_toolbar.frame)*0.5);
    [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotion"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotionhighlighted"] forState:UIControlStateHighlighted];
    [_emojiButton addTarget:self action:@selector(showEmojiKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar addSubview:_emojiButton];
    
    [self.view addSubview:_toolbar];
}
#pragma mark - 发表
-(void)postArticle{
    NSLog(@"_imagesContainer.contentSize %@",NSStringFromCGSize(_imagesContainer.contentSize));
    NSLog(@"_imagesContainer.frame %@",NSStringFromCGRect(_imagesContainer.frame));
    
    NSMutableString *contentString=[[NSMutableString alloc]init];
    for(int i=0;i<_contentTextView.attributedText.length;i++){
        if([_contentTextView.attributedText attribute:YYTextAttachmentAttributeName atIndex:i]){
            YYTextAttachment *attachment=[_contentTextView.attributedText attribute:YYTextAttachmentAttributeName atIndex:i];
            CustomYYAnimatedImageView *imageView=attachment.content;
            [contentString appendString:imageView.imageString];
        }
        else
            [contentString appendString:[_contentTextView.text substringWithRange:NSMakeRange(i, 1)]];
    }
    NSLog(@"%@",contentString);
    NSString *message=nil;
    if(_isNewTheme)
        message=@"确认发表新话题？";
    else
        message=@"确认回复该话题？";
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"发表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self disableInteraction];
        [SVProgressHUD showWithStatus:@"发表中"];
        [PostArticleUtilities postArticleWithBoardName:_boardName withArticleTitle:_titleTextField.text withArticleContent:contentString isNewTheme:_isNewTheme withReplyArticleID:_articleId delegate:self];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 发表过程中开关别的控件响应
-(void)disableInteraction{
    if(!_dummyView){
        _dummyView=[[UIView alloc]initWithFrame:kCustomScreenBounds];
        _dummyView.backgroundColor=[UIColor clearColor];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_dummyView];
}
-(void)enableInteraction{
    [_dummyView removeFromSuperview];
    _dummyView=nil;
}
#pragma mark - 实现HttpResponseDelegate协议
-(void)handleHttpSuccessResponse:(id)response{
    [self enableInteraction];
    [SVProgressHUD showSuccessWithStatus:@"发表成功"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
-(void)handleHttpErrorResponse:(id)response{
    [self enableInteraction];
    NSError *error=(NSError *)response;
    NetworkErrorCode errorCode=[CustomUtilities getNetworkErrorCode:error];
    switch (errorCode) {
        case NetworkConnectFailed:
            [SVProgressHUD showErrorWithStatus:@"网络连接已断开"];
            break;
        case NetworkConnectTimeout:
            [SVProgressHUD showErrorWithStatus:@"网络连接超时"];
            break;
        case NetworkConnectUnknownReason:
            [SVProgressHUD showErrorWithStatus:@"好像出现了某种奇怪的问题"];
            break;
        default:
            break;
    }
}


#pragma mark - 监听键盘相关通知
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *dic=notification.userInfo;
    CGRect frame=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat timeInterval=[[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger curve=[[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationCurve:curve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect newFrame=_toolbar.frame;
        newFrame.origin.y=CGRectGetMinY(frame)-CGRectGetHeight(_toolbar.frame);
        _toolbar.frame=newFrame;
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    NSDictionary *dic=notification.userInfo;
    CGRect frame=[[dic valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat timeInterval=[[dic valueForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    NSInteger curve=[[dic valueForKey:UIKeyboardAnimationCurveUserInfoKey]integerValue];
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationCurve:curve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect newFrame=_toolbar.frame;
        newFrame.origin.y=CGRectGetMinY(frame)-CGRectGetHeight(_toolbar.frame);
        _toolbar.frame=newFrame;
    }];
}


#pragma mark - 显示图片选择
-(void)choosePicture{
    UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableArray *array=[[NSMutableArray alloc]init];
    UIImagePickerController *imagePickerController=[[UIImagePickerController alloc]init];
    imagePickerController.delegate=self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"拍摄照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePickerController animated:YES completion:nil];
        }];
        [array addObject:action];
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePickerController animated:YES completion:nil];
        }];
        [array addObject:action];
    }
   
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [array addObject:action];
    
    for(int i=0;i<array.count;i++)
        [controller addAction:[array objectAtIndex:i]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 实现UIImagePickerControllerDelegate协议
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [_imageAttachments addObject:image];
    [_imagesContainer reloadData];
    if(_imageAttachments.count%3==1){
        NSInteger lineSpacingCount=_imageAttachments.count/3;
  
        _imagesContainer.contentSize=CGSizeMake(_imagesContainer.contentSize.width, kImageSize+kImageSize*lineSpacingCount+lineSpacingCount*kMargin);
    }
    [self _refreshScrollViewFrame];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 显示表情键盘
-(void)showEmojiKeyboard{
    if(_contentTextView.inputView==_emojiKeyboard){
        _contentTextView.inputView=nil;
        [_contentTextView reloadInputViews];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotion"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbaremotionhighlighted"] forState:UIControlStateHighlighted];
    }
    else{
        _contentTextView.inputView=_emojiKeyboard;
        [_contentTextView reloadInputViews];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbarkeyboard"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"toolbarkeyboardhighlighted"] forState:UIControlStateHighlighted];
        
        if(![_contentTextView isFirstResponder])
            [_contentTextView becomeFirstResponder];
    }
}


#pragma mark - 实现CustomEmojiKeyboardDelegate
-(void)addEmojiWithImage:(YYImage *)image withImageString:(NSString *)imageString{
    UIFont*font=_contentTextView.font;
    CGFloat imageViewWidth=font.ascender-font.descender+6;
    CustomYYAnimatedImageView *imageview=[[CustomYYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewWidth)];
    imageview.imageString=imageString;
    
    NSRange range;
    range.location=1;
    range.length=imageString.length-2;
    imageview.image=[YYImage imageNamedFromEmojiBundle:[imageString substringWithRange:range]];
    NSMutableAttributedString *tmp=[NSMutableAttributedString attachmentStringWithContent:imageview contentMode:UIViewContentModeCenter attachmentSize:imageview.frame.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    tmp.font=font;
    
    NSMutableAttributedString *res=[[NSMutableAttributedString alloc]initWithAttributedString:_contentTextView.attributedText];
    NSRange selectedRange=_contentTextView.selectedRange;
    [res replaceCharactersInRange:selectedRange  withAttributedString:tmp];
    _contentTextView.attributedText=res;
    
    selectedRange.location++;
    _contentTextView.selectedRange=selectedRange;
}

-(void)deleteEmoji{
    [_contentTextView deleteBackward];
}


#pragma mark - 实现YYTextViewDelegate
-(void)textViewDidChange:(YYTextView *)textView{
    [self _refreshScrollViewFrame];
}
-(void)textViewDidBeginEditing:(YYTextView *)textView{
    [self _refreshScrollViewFrame];
}

#pragma mark - 实现UICollectionView Datasource协议
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_imageAttachments count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ReplyViewImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.image=_imageAttachments[indexPath.row];
    return cell;
}


#pragma mark - 实现UICollectionViewDelegateFlowLayout协议
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kImageSize, kImageSize);
}


#pragma mark - 更新scrollviewframe
-(void)_refreshScrollViewFrame{
//    NSLog(@"*****************************************");
//    NSLog(@"_scrollview.contentOffset %@",NSStringFromCGPoint(_scrollview.contentOffset));
//    NSLog(@"_contentTextView.contentOffset %@",NSStringFromCGPoint(_contentTextView.contentOffset));

    _contentTextView.frame=CGRectMake(CGRectGetMinX(_contentTextView.frame), CGRectGetMinY(_contentTextView.frame), CGRectGetWidth(_contentTextView.frame), _contentTextView.contentSize.height+20);
    _imagesContainer.frame=CGRectMake(CGRectGetMinX(_imagesContainer.frame), CGRectGetMaxY(_contentTextView.frame), CGRectGetWidth(_imagesContainer.frame),_imagesContainer.contentSize.height);
    _scrollview.contentSize=CGSizeMake(_scrollview.contentSize.width, CGRectGetHeight(_contentTextView.frame)+CGRectGetHeight(_imagesContainer.frame)+CGRectGetHeight(self.view.frame)/2.0);
    
    CGPoint point=[_contentTextView caretRectForPosition:_contentTextView.selectedTextRange.start].origin;
   
    CGFloat cursorY=kNavigationBarHeight+kSeperatorViewHeight+kTitleTextFiledHeight+point.y+25.5;
//    NSLog(@"%@",NSStringFromCGRect(_toolbar.frame));
    if(cursorY>CGRectGetMinY(_toolbar.frame)){
        CGPoint newOffset=CGPointMake(0, -(kNavigationBarHeight+kSeperatorViewHeight+kTitleTextFiledHeight)+cursorY-CGRectGetMinY(_toolbar.frame));
        if(newOffset.y>_scrollview.contentOffset.y)
            _scrollview.contentOffset=newOffset;
    }
//     NSLog(@"_scrollview.contentOffset %@",NSStringFromCGPoint(_scrollview.contentOffset));
//    NSLog(@"_point %@",NSStringFromCGPoint(point));
//    NSLog(@"_contentTextView.frame %@",NSStringFromCGRect(_contentTextView.frame));
//    NSLog(@"_scrollview.contentSize %@",NSStringFromCGSize(_scrollview.contentSize));
}
@end
