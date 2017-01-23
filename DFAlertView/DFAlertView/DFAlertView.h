//
//  DFAlertView.h
//  DFckNetApp
//
//  Created by 全程恺 on 16/12/9.
//  Copyright © 2016年 xmisp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    DFAlertStyleDefault,    //居中警告，带黑色标题和内容，居中
    DFAlertStyleSuccess,    //居中警告，成功
    DFAlertStyleFailure,    //居中警告，失败
} DFAlertStyle;

typedef enum {
    DFAlertActionStyleDefault = 0,
    DFAlertActionStyleCancel,
    DFAlertActionStyleDestructive
} DFAlertActionStyle;

@class DFAlertView;
@interface DFAlertAction : NSObject

+ (instancetype _Nonnull)actionWithTitle:(NSString * _Nonnull)title style:(DFAlertActionStyle)style handler:(void (^ _Nullable)(DFAlertAction * _Nonnull action, DFAlertView * _Nonnull alertView))handler;

@property (retain, nonatomic, nullable) UIFont *font; //默认14
@property (retain, nonatomic, nullable) UIColor *titleColor;  //默认主题色
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;         //默认yes
@end

@interface DFAlertView : UIView

@property (nonatomic, strong, nonnull) UILabel       *messageLabel;
@property (nonatomic, strong, nonnull) UILabel       *titleLabel;
//输入框，只有实现了addtextfield这个方法才有值
@property (nonatomic, strong, nullable, readonly) NSMutableArray *textFields;
//是否要手动移除，默认是否
@property (assign, nonatomic) BOOL removeUntilCall;

/*自定义弹框样式
 *  参数解释:
 *  style:  提示样式
 *  title:  标题（加粗字体）
 *  tip:    提示信息，可不传
 *  示例：
 
 DFAlertView *alert = [[DFAlertView alloc] initWithStyle:DFAlertStyleDefault title:@"这是一个为了凑满换行而努力的标题！" message:@"备注如果需要换行的话也随手凑凑字数看看吧"];
 //等主动调用方法的时候再移除，避免点击按钮的时候就消失。如果是NO，则点了按钮以后自动移除弹框。默认为NO
 alert.removeUntilCall = YES;
 DFAlertAction *action1 = [DFAlertAction actionWithTitle:@"取消" style:DFAlertActionStyleDestructive handler:^(DFAlertAction * _Nonnull action, DFAlertView * _Nonnull alertView) {
 
 [alertView removeCompletion:^(BOOL finished) {
 
 NSLog(@"移除成功");
 }];
 }];
 DFAlertAction *action2 = [DFAlertAction actionWithTitle:@"确定" style:DFAlertActionStyleDefault handler:^(DFAlertAction *action, DFAlertView *lertView) {
 
 NSLog(@"点取消移除");
 }];
 
 [alert addAction:action1];
 [alert addAction:action2];
 
 [alert addTextField:^(UITextField *textField) {
 
 textField.placeholder = @"请输入xxx1";
 }];
 
 [alert addTextField:^(UITextField *textField) {
 
 textField.placeholder = @"请输入xxx2";
 }];
 
 [alert addTextField:^(UITextField *textField) {
 
 textField.placeholder = @"请输入xxx3";
 }];
 
 [alert showInView:self.view];
 */
- (instancetype _Nonnull)initWithStyle:(DFAlertStyle)style title:(NSString * _Nonnull)title message:(NSString * _Nullable)tip;

//增加点击行为
- (void)addAction:(DFAlertAction * _Nonnull)action;
//可以一个或多个，建议有按钮，否则无法回收弹框
- (void)addActions:(NSArray * _Nonnull)actions;

- (void)addTextField:(void (^ _Nullable)(UITextField * _Nonnull textField))configueHandler;

- (void)showInView:(UIView * _Nonnull)view;

- (void)removeCompletion:(void (^ __nullable)(BOOL finished))completion;

@end
