//
//  SubThemeViewController.m
//  bupt
//
//  Created by 邱鑫玥 on 15/12/10.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "SubThemeViewController.h"

@interface SubThemeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *numOfPagesLabel;
@property (weak, nonatomic) IBOutlet UITextView *destinationTextView;
@end

@implementation SubThemeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.numOfPagesLabel.text=[NSString stringWithFormat:@"共有%d页",self.page_all_count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancleButtonPressed:(id)sender {
    [self.themViewController.wyPopoverController dismissPopoverAnimated:YES];
    self.themViewController.wyPopoverController.delegate=nil;
    self.themViewController.wyPopoverController=nil;
}
- (IBAction)jumpButtonPressed:(id)sender {
    int nextPage=[self.destinationTextView.text intValue];
    if(nextPage<=0||nextPage>self.page_all_count){
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:@"错误的页码！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"重新输入" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
        [self.themViewController jumpToRefresh:nextPage];
}


@end
