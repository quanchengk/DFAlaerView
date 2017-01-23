//
//  DFAlertView.m
//  DFckNetApp
//
//  Created by 全程恺 on 16/12/9.
//  Copyright © 2016年 xmisp. All rights reserved.
//

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kColorBlackDark   0x000000    //深黑
#define kColorBlackNormal 0x333333  //正常黑
#define kColorBlackLight  0x666666   //浅黑
#define kColorGrayNormal  0xf3f4f6   //正常灰
#define kColorGrayLight   0xe2e2e2   //浅灰（线的颜色）
#define kColorWhite       0xffffff    //白色
#define kColorGreen       0x0db43d    //绿色
#define kColorRed         0xd20000    //红色
#define kColorYellow      0xfe8600    //橙黄
#define kColorBlue        0x3b87ee    //点击蓝
#define kColorGrayDrak    0xf0f0f6    //深灰

#define kFontSize(font) [UIFont systemFontOfSize:font]
#define kFontBoldSize(font) [UIFont boldSystemFontOfSize:font]

#define kHeightButton 45

#import "DFAlertView.h"
#import <Masonry.h>

@interface DFAlertAction ()

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) void (^handler)(DFAlertAction *, DFAlertView *);
@property (retain, nonatomic) UIButton *button; //按钮本身

@end

@implementation DFAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(DFAlertActionStyle)style handler:(void (^ _Nullable)(DFAlertAction * _Nonnull, DFAlertView * _Nonnull))handler {
    
    DFAlertAction *action = [DFAlertAction new];
    action.title = title;
    action.handler = handler;
    action.enabled = YES;
    switch (style) {
        case DFAlertActionStyleCancel:
            action.font = kFontSize(17);
            action.titleColor = HEXCOLOR(kColorBlue);
            break;
            
        case DFAlertActionStyleDestructive:
            action.font = kFontBoldSize(17);
            action.titleColor = HEXCOLOR(kColorRed);
            break;
            
        default:
            action.font = kFontBoldSize(15);
            action.titleColor = HEXCOLOR(kColorBlue);
            break;
    }
    
    return action;
}

- (UIButton *)button {
    
    if (!_button) {
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:self.title forState:UIControlStateNormal];
        [_button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [_button setTitleColor:HEXCOLOR(kColorGrayNormal) forState:UIControlStateSelected];
        [_button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        _button.titleLabel.font = self.font;
        _button.selected = !self.isEnabled;
        
        UIView *line = [UIView new];
        line.backgroundColor = HEXCOLOR(kColorGrayLight);
        [_button addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(_button);
            make.left.equalTo(_button);
            make.right.equalTo(_button);
            make.height.mas_equalTo(1);
        }];
    }
    
    return _button;
}

- (void)clickAction {
    
    DFAlertView *alertView;// = [DFHelper getTargetClass:[DFAlertView class] fromObject:self.button];
    
    UIResponder *next = [self.button nextResponder];
    do {
        if ([next isKindOfClass:[DFAlertView class]]) {
            
            alertView = (DFAlertView *)next;
            break;
        }
        next =[next nextResponder];
    }
    while (next != nil);
    
    if (alertView.removeUntilCall) {
        
        //需要手动调用移除方法
        if (self.handler) {
            
            //        [loadingView performSelectorOnMainThread:@selector(removeAnimate) withObject:nil waitUntilDone:YES];
            self.handler(self, alertView);
        }
    }
    else {
        
        [alertView removeCompletion:^(BOOL finished) {
            
            if (self.handler) {
                
                //        [loadingView performSelectorOnMainThread:@selector(removeAnimate) withObject:nil waitUntilDone:YES];
                self.handler(self, alertView);
            }
        }];
    }
}

@end

@interface DFAlertView () <CAAnimationDelegate>

@property (nonatomic, strong) UIView        *backgroundView;
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UIView        *bottonsView;
@property (nonatomic, retain) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, assign) DFAlertStyle style;

@end

@implementation DFAlertView

- (instancetype)initWithStyle:(DFAlertStyle)style title:(NSString *)title message:(NSString *)tip {
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)]) {
        
        _style = style;
        self.backgroundColor = [HEXCOLOR(kColorBlackDark) colorWithAlphaComponent:.4];
        CGFloat spaceLeft = 24;
        CGFloat spaceRight = -24;
        CGFloat spaceTop = 24;
        CGFloat spaceBottom = -24;
        CGFloat spaceVertical = 16;
        CGFloat backgroundViewSpaceLeft = 105.0 / 2;
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(backgroundViewSpaceLeft, 0, screenRect.size.width - backgroundViewSpaceLeft * 2, 0)];
        _backgroundView.backgroundColor = HEXCOLOR(kColorWhite);
        _backgroundView.layer.cornerRadius = 9;
        _backgroundView.layer.masksToBounds = YES;
        [self addSubview:_backgroundView];
        
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(_backgroundView.frame.size.width);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        _bottonsView = [UIView new];
        [_backgroundView addSubview:_bottonsView];
        
        if (title.length) {
            
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.textColor = HEXCOLOR(kColorBlackDark);
            _titleLabel.font = kFontSize(17);
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.numberOfLines = 0;
            _titleLabel.preferredMaxLayoutWidth = _backgroundView.frame.size.width - spaceLeft + spaceRight;
            _titleLabel.text = title;
            [_backgroundView addSubview:_titleLabel];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(_backgroundView).offset(spaceTop);
                make.left.equalTo(_backgroundView).offset(spaceLeft);
                make.right.equalTo(_backgroundView).offset(spaceRight);
            }];
        }
        
        if (style == DFAlertStyleSuccess ||
            style == DFAlertStyleFailure) {
            
            _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:style == DFAlertStyleSuccess ? @"icon_popup_success" : @"icon_popup_fail"]];
            [_backgroundView addSubview:_iconView];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(_backgroundView).offset(spaceTop);
                make.left.equalTo(_backgroundView).offset(spaceLeft);
                make.right.equalTo(_backgroundView).offset(spaceRight);
            }];
            
            [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(_titleLabel.mas_bottom).offset(spaceVertical);
                make.size.mas_equalTo(_iconView.frame.size);
                make.centerX.equalTo(_backgroundView);
            }];
        }
        
        if (tip.length) {
            
            _messageLabel = [UILabel new];
            _messageLabel.textColor = HEXCOLOR(kColorBlackLight);
            _messageLabel.font = kFontSize(15);
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.numberOfLines = 0;
            _messageLabel.text = tip;
            _messageLabel.preferredMaxLayoutWidth = _titleLabel.preferredMaxLayoutWidth;
            [_backgroundView addSubview:_messageLabel];
            
            [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(_iconView ? _iconView.mas_bottom : _titleLabel.mas_bottom).offset(spaceVertical);
                make.left.equalTo(_backgroundView).offset(spaceLeft);
                make.right.equalTo(_backgroundView).offset(spaceRight);
            }];
        }
        
        UIView *lastObj = _titleLabel;
        if (_iconView) {
            
            lastObj = _iconView;
        }
        if (_messageLabel) {
            
            lastObj = _messageLabel;
        }
        
        [_bottonsView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (lastObj)
                make.top.equalTo(lastObj.mas_bottom).offset(-spaceBottom);
            else
                make.top.equalTo(_backgroundView).offset(spaceTop);
            make.left.bottom.right.equalTo(_backgroundView);
        }];
        
        self.alpha = 0;
    }
    
    return self;
}

- (void)addTextField:(void (^)(UITextField *))configureHandler {
    
    UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, _titleLabel.preferredMaxLayoutWidth, 33)];
    inputField.layer.cornerRadius = 4;
    inputField.layer.masksToBounds = YES;
    inputField.layer.borderColor = HEXCOLOR(kColorGrayLight).CGColor;
    inputField.layer.borderWidth = .5;
    inputField.textColor = HEXCOLOR(kColorBlackNormal);
    inputField.backgroundColor = HEXCOLOR(kColorWhite);
    inputField.font = kFontSize(14);
    inputField.clearButtonMode = UITextFieldViewModeAlways;
    inputField.textAlignment = NSTextAlignmentCenter;
    _backgroundView.backgroundColor = HEXCOLOR(0xf4f4f4);
    [_backgroundView addSubview:inputField];
    
    UITextField *lastTF = [self.textFields lastObject];
    
    [self.textFields addObject:inputField];
    
    [inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(inputField.frame.size);
        make.centerX.equalTo(_backgroundView);
        if (lastTF) {
            make.top.equalTo(lastTF.mas_bottom).offset(8);
        }
        else {
            
            UIView *lastObj = _titleLabel;
            if (_iconView) {
                
                lastObj = _iconView;
            }
            if (_messageLabel) {
                
                lastObj = _messageLabel;
            }
            
            make.top.equalTo(lastObj.mas_bottom).offset(16);
        }
    }];
    
    [_bottonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(inputField.mas_bottom).offset(16);
        make.left.bottom.right.equalTo(_backgroundView);
    }];
    
    configureHandler(inputField);
}

- (void)addAction:(DFAlertView *)action {
    
    [self addActions:@[action]];
}

- (void)addActions:(NSArray *)actions {
    
    for (DFAlertAction *action in actions) {
        
        NSAssert([action isKindOfClass:[DFAlertAction class]], @"按钮类型错误");
        [_bottonsView addSubview:action.button];
        [self.actions addObject:action];
    }
    
    //重新布局
    if (self.actions.count <= 2) {
        
        //左右布局
        [self horizontallyButtons:self.actions];
    }
    else {
        
        //上下布局
        [self verticallyButtons:self.actions];
    }
}

- (void)horizontallyButtons:(NSArray *)actions
{
    if (!actions.count) {
        
        return;
    }
    DFAlertAction *firstAction = actions[0];
    
    [firstAction.button mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.equalTo(_bottonsView);
        make.left.equalTo(_bottonsView);
        make.height.mas_equalTo(kHeightButton);
    }];
    
    UIButton *lastView = firstAction.button;
    for (int i = 1; i < actions.count; i++) {
        
        DFAlertAction *action = actions[i];
        UIButton *view = action.button;
        
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(lastView.mas_right);
            make.width.top.bottom.height.equalTo(lastView);
        }];
        
        UIView *line = [UIView new];
        line.backgroundColor = HEXCOLOR(kColorGrayLight);
        [lastView addSubview:line];
        
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(lastView);
            make.top.equalTo(lastView);
            make.bottom.equalTo(lastView);
            make.width.mas_equalTo(1);
        }];
        
        lastView = view;
    }
    
    if (![lastView isEqual:firstAction.button]) {
        
        [firstAction.button mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(lastView);
        }];
    }
    
    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(_bottonsView);
    }];
}

- (void)verticallyButtons:(NSArray *)actions {
    
    if (!actions.count) {
        
        return;
    }
    DFAlertAction *firstAction = actions[0];
    
    [firstAction.button mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.equalTo(_bottonsView);
        make.height.mas_equalTo(kHeightButton);
    }];
    
    UIButton *lastView = firstAction.button;
    for (int i = 1; i < actions.count; i++) {
        
        DFAlertAction *action = actions[i];
        UIButton *view = action.button;
        
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(lastView.mas_bottom);
            make.left.right.equalTo(lastView);
            make.height.mas_equalTo(kHeightButton);
        }];
        
        UIView *line = [UIView new];
        line.backgroundColor = HEXCOLOR(kColorGrayLight);
        [lastView addSubview:line];
        
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(lastView);
            make.left.equalTo(lastView);
            make.right.equalTo(lastView);
            make.height.mas_equalTo(1);
        }];
        
        lastView = view;
    }
    
    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(_bottonsView);
    }];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = frame.origin.y;
    self.frame = CGRectMake(0, 0, self.frame.size.width, height);
    
    [UIView animateWithDuration:.2 animations:^{
        
        [self layoutIfNeeded];
    }];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = frame.origin.y;
    self.frame = CGRectMake(0, 0, self.frame.size.width, height);
    
    [UIView animateWithDuration:.2 animations:^{
        
        [self layoutIfNeeded];
    }];
}

- (void)showInView:(UIView *)view {
    
    [self layoutIfNeeded];
    
    [view addSubview:self];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.5;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    popAnimation.delegate = self;
    [_backgroundView.layer addAnimation:popAnimation forKey:nil];
    _backgroundView.transform = CGAffineTransformScale(self.transform,1,1);
    
    [UIView animateWithDuration:.2 animations:^{
        
        self.alpha = 1;
    }];
    
    if (_textFields.count) {
        
        UITextField *tf = _textFields[0];
        [tf becomeFirstResponder];
    }
}

- (void)removeCompletion:(void (^ __nullable)(BOOL finished))completion {
    
    [UIView animateWithDuration:.2 animations:^{
        
        _backgroundView.transform = CGAffineTransformScale(self.transform, .1, .1);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        completion(finished);
    }];
}

- (NSMutableArray *)actions {
    
    if (!_actions) {
        
        _actions = [NSMutableArray array];
    }
    
    return _actions;
}

- (NSMutableArray *)textFields {
    
    if (!_textFields) {
        
        _textFields = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    return _textFields;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    
    self.userInteractionEnabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //备选方案
        self.userInteractionEnabled = YES;
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.userInteractionEnabled = NO;
    if (flag) {
        
        self.userInteractionEnabled = YES;
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
