//
//  LQAlertConfig.h
//  LQAlertView
//
//  Created by kingsoft on 2017/8/16.
//  Copyright © 2017年 Liuquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 一个或两个按钮
typedef NS_ENUM(NSInteger, LQAlertViewButtonType) {
    LQAlertViewButtonType_One,
     LQAlertViewButtonType_Two
};

/// alert 样式
typedef NS_ENUM(NSInteger, LQAlertViewType) {
    LQAlertViewType_Default = 0, /// 默认
    LQAlertViewType_Input,  /// 一个输入框
    LQAlertViewType_Password /// 密码输入
};

@interface LQAlertConfig : NSObject

///  common
@property (nonatomic, copy) NSString *title; /// 标题
@property (nonatomic, strong) UIFont *titleFont;/// 标题大小
@property (nonatomic, strong) UIColor *titleColor;/// 标题颜色
@property (nonatomic, strong) UIImage *backImage;/// alert背景图
@property (nonatomic, strong) NSArray<NSString *>*btnBackImageArr;/// 按钮背景图
@property (nonatomic, strong) NSArray<NSString *>*btnBackColorArr;/// 按钮背景颜色
@property (nonatomic, strong) NSArray<NSString *>*btnTitleArr;/// 按钮标题
@property (nonatomic, strong) NSArray<NSString *>*btnTitleColorArr;///按钮title颜色
@property (nonatomic, assign) BOOL isHidenAlert;///点击空白处是否隐藏alert。默认 NO
@property (nonatomic, assign) LQAlertViewButtonType buttonType;///一个或两个按钮
@property (nonatomic, assign) LQAlertViewType alertType;/// alert 样式

/// default type
@property (nonatomic, strong) UIFont *contentFont;
@property (nonatomic, strong) UIColor *contentColor;
@property (nonatomic, copy) NSString *content;


/// Input type
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *inputBackColor;
@property (nonatomic, strong) UIColor *inputTextColor;
@property (nonatomic, strong) UIFont *inputFont;
@property (nonatomic, strong) NSString *promptString;

/// password type
@property (nonatomic, strong) NSArray *placeholders;


///  初始化标题和内容，适合default type
+ (instancetype)initAlertWithTitle:(NSString *)title alertContent:(NSString *)content;

@end
