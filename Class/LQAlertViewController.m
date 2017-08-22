//
//  LQAlertViewController.m
//  LQAlertView
//
//  Created by kingsoft on 2017/8/18.
//  Copyright © 2017年 Liuquan. All rights reserved.
//

#import "LQAlertViewController.h"

#import "LQAlertConfig.h"
#import "Masonry.h"
#import "UIViewController+LQPresentQueue.h"

#define IPHONE5         ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IPHONE6         ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen]currentMode].size) : NO)
#define IPHONE6P        ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define kContentViewMargin  IPHONE5 ? 30 : IPHONE6 ? 50 : 70
#define kTextFieldTag  1
#define kSureButtonTag  100
#define kCancelButtonTag 101


@interface LQAlertViewController ()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) LQAlertConfig *config;
@end

@implementation LQAlertViewController

+ (instancetype)showAlertViewWithConfig:(LQAlertConfig *)alertConfig clickComplete:(LQAlertViewClickBlock)clickBlock {
    LQAlertViewController *alertController = [[LQAlertViewController alloc] initAlertWithConfig:alertConfig clickComplete:clickBlock];
    return alertController;
}

- (instancetype)initAlertWithConfig:(LQAlertConfig *)config clickComplete:(LQAlertViewClickBlock)clickBlock {
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.view.backgroundColor = [UIColor clearColor];
        _clickBlock = clickBlock;
        [self setDefaultUI:config];
        [self differentTypeWithConfig:config];
        _config = config;
        /// 监听键盘状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboadWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setDefaultUI:(LQAlertConfig *)config {
    
    UIView *backView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backView = backView;
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:backView];
    
    if (config.isHidenAlert) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenAlertView)];
        [backView addGestureRecognizer:tap];
    }
   
    UIView *contentView = [[UIView alloc] init];
    self.contentView = contentView;
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    contentView.backgroundColor = [UIColor whiteColor];
    [backView addSubview:contentView];

    UIImageView *backImage = [[UIImageView alloc] init];
    backImage.image = config.backImage;
    backImage.image = [config.backImage stretchableImageWithLeftCapWidth:config.backImage.size.width * 0.4 topCapHeight:config.backImage.size.height * 0.4];
    [self.contentView addSubview:backImage];
    
    [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.font = config.titleFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = config.titleColor;
    titleLabel.text = config.title;
    [self.contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView.mas_top).offset(25);
        make.left.mas_equalTo(contentView.mas_left).offset(0);
        make.right.mas_equalTo(contentView.mas_right).offset(0);
        make.height.mas_equalTo(20);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sureBtn = sureBtn;
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureBtn setTitle:[config.btnTitleArr lastObject] forState:UIControlStateNormal];
    sureBtn.backgroundColor = [self colorWithHexString:[config.btnBackColorArr lastObject]];
    [sureBtn setTitleColor:[self colorWithHexString:[config.btnTitleColorArr lastObject]] forState:UIControlStateNormal];
    sureBtn.tag = kSureButtonTag;
    sureBtn.layer.cornerRadius = 3;
    sureBtn.layer.masksToBounds = YES;
    [sureBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:sureBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn = cancelBtn;
    [cancelBtn setTitle:[config.btnTitleArr firstObject] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn setTitleColor:[self colorWithHexString:[config.btnTitleColorArr firstObject]] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [self colorWithHexString:[config.btnBackColorArr firstObject]];
    cancelBtn.tag = kCancelButtonTag;
    cancelBtn.layer.cornerRadius = 3;
    cancelBtn.layer.masksToBounds = YES;
    [cancelBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelBtn];
}

/// different type ------> UI
- (void)differentTypeWithConfig:(LQAlertConfig *)config {
    switch (config.alertType) {
        case LQAlertViewType_Default: {
            [self setDefaultUIWithConfig:config];
        }
            break;
        case LQAlertViewType_Input: {
            [self setInputAlertViewWithConfig:config];
        }
            break;
        case LQAlertViewType_Password: {
            
        }
            break;
        default:
            break;
    }
}

///  default alert view
- (void)setDefaultUIWithConfig:(LQAlertConfig *)config {

    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = config.contentFont;
    contentLabel.textColor = config.contentColor;
    contentLabel.text = config.content;
    contentLabel.numberOfLines = 0;
    [self.contentView addSubview:contentLabel];
    
    if (config.buttonType == LQAlertViewButtonType_One) {
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-30);
            make.left.mas_equalTo(self.contentView.mas_left).offset(30);
            make.top.mas_equalTo(contentLabel.mas_bottom).offset(15);
            make.height.mas_equalTo(30);
        }];
    } else {
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(20);
            make.right.mas_equalTo(self.sureBtn.mas_left).offset(-20);
            make.top.mas_equalTo(contentLabel.mas_bottom).offset(15);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.sureBtn);
        }];
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.left.mas_equalTo(self.cancelBtn.mas_right).offset(20);
            make.top.mas_equalTo(contentLabel.mas_bottom).offset(15);
            make.height.mas_equalTo(30);
        }];
    }
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(5);
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.left.mas_equalTo(self.backView.mas_left).offset(kContentViewMargin);
        make.bottom.mas_equalTo(self.sureBtn.mas_bottom).offset(20);
    }];
}

/// input alert view
- (void)setInputAlertViewWithConfig:(LQAlertConfig *)config {
    UITextField *textFiled = [[UITextField alloc] init];
    textFiled.backgroundColor =config.inputBackColor;
    textFiled.borderStyle = UITextBorderStyleNone;
    textFiled.tag = 1;
    textFiled.placeholder = config.placeholder;
    textFiled.font = config.inputFont;
    textFiled.layer.cornerRadius = 3;
    textFiled.layer.masksToBounds = YES;
    textFiled.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:textFiled];
    
    UILabel *signLabel = [[UILabel alloc] init];
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.text = config.promptString;
    signLabel.font = [UIFont systemFontOfSize:12];
    signLabel.textColor = [self colorWithHexString:@"#DCDCDC"];
    signLabel.numberOfLines = 0;
    [self.contentView addSubview:signLabel];
    
    [textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(30);
    }];
    
    [signLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sureBtn.mas_bottom).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    if (config.buttonType == LQAlertViewButtonType_One) {
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-30);
            make.left.mas_equalTo(self.contentView.mas_left).offset(30);
            make.top.mas_equalTo(textFiled.mas_bottom).offset(15);
            make.height.mas_equalTo(30);
        }];
    } else {
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(20);
            make.right.mas_equalTo(self.sureBtn.mas_left).offset(-20);
            make.top.mas_equalTo(textFiled.mas_bottom).offset(15);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.sureBtn);
        }];
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.left.mas_equalTo(self.cancelBtn.mas_right).offset(20);
            make.top.mas_equalTo(textFiled.mas_bottom).offset(15);
            make.height.mas_equalTo(30);
        }];
    }
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.left.mas_equalTo(self.backView.mas_left).offset(40);
        make.bottom.mas_equalTo(signLabel.mas_bottom).offset(10);
    }];
    
}

#pragma mark - click action
- (void)buttonAction:(UIButton *)sender {
    if (self.config.alertType != LQAlertViewType_Default) {[self.view endEditing:YES];}
    if (self.clickBlock) {
        self.clickBlock(self.contentView, sender.tag);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hidenAlertView {
      [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - color
- (UIColor *)colorWithHexString: (NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {return [UIColor clearColor];}
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor clearColor];

    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark - key board state
- (void)keyboadWillShow:(NSNotification *)notify {
    [self.view layoutIfNeeded];
    CGFloat animateTime = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animateTime animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backView.mas_centerY).offset(-60);
        }];
         [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHiden:(NSNotification *)notify {
     [self.view layoutIfNeeded];
    CGFloat animateTime = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animateTime animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backView.mas_centerY);
        }];
         [self.view layoutIfNeeded];
    }];
}



- (void)dealloc {
    
    NSLog(@"释放了。。。。。。。。");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end
