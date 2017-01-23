//
//  ViewController.m
//  DFAlertView
//
//  Created by 全程恺 on 17/1/23.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import "ViewController.h"
#import "DFAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DFAlertView *alert = [[DFAlertView alloc] initWithStyle:DFAlertStyleSuccess title:@"这是一个为了凑满换行而努力的标题！" message:@"备注如果需要换行的话也随手凑凑字数看看吧"];
    //等主动调用方法的时候再移除，避免点击按钮的时候就消失。如果是NO，则点了按钮以后自动移除弹框。默认为NO
    alert.removeUntilCall = YES;
    DFAlertAction *action1 = [DFAlertAction actionWithTitle:@"取消" style:DFAlertActionStyleCancel handler:^(DFAlertAction * _Nonnull action, DFAlertView * _Nonnull alertView) {
        
        [alertView removeCompletion:^(BOOL finished) {
            
            NSLog(@"移除成功");
        }];
    }];
    DFAlertAction *action2 = [DFAlertAction actionWithTitle:@"确定" style:DFAlertActionStyleDefault handler:^(DFAlertAction *action, DFAlertView *lertView) {
        
        NSLog(@"点取消移除");
    }];
    DFAlertAction *action3 = [DFAlertAction actionWithTitle:@"(⊙o⊙)" style:DFAlertActionStyleDestructive handler:^(DFAlertAction *action, DFAlertView *lertView) {
        
        NSLog(@"(⊙o⊙)");
    }];
    
//    [alert addAction:action1];
//    [alert addAction:action2];
    [alert addActions:@[action1, action2, action3]];
    
    [alert addTextField:^(UITextField *textField) {
        
        textField.placeholder = @"请输入xxx1";
    }];
    
    [alert addTextField:^(UITextField *textField) {
        
        textField.placeholder = @"请输入xxx2";
    }];
    
//    [alert addTextField:^(UITextField *textField) {
//        
//        textField.placeholder = @"请输入xxx3";
//    }];
    
    [alert showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
