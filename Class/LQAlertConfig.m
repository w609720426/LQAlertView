//
//  LQAlertConfig.m
//  LQAlertView
//
//  Created by kingsoft on 2017/8/16.
//  Copyright © 2017年 Liuquan. All rights reserved.
//

#import "LQAlertConfig.h"

@implementation LQAlertConfig

+ (instancetype)initAlertWithTitle:(NSString *)title alertContent:(NSString *)content {
    
    return [[self alloc] initAlertWithTitle:title alertContent:content];
    
}

- (instancetype)initAlertWithTitle:(NSString *)title alertContent:(NSString *)content {
    
    self = [super init];
    
    if (self) {
        
        _title = title;
        _content = content;
      
        [self setDefaultParams];
        
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        [self setDefaultParams];
        
    }
    
    return self;
    
}

- (void)setDefaultParams {
    if (_title == nil) _title = @"设置标题";
    _titleFont = [UIFont systemFontOfSize:16.0];
     _titleColor = [UIColor blackColor];
    _backImage = nil;
    _btnBackImageArr = nil;
    _btnTitleColorArr = @[@"FFFFFF",@"FFFFFF"];
    _btnTitleArr = @[@"取消",@"确定"];
    _btnBackColorArr = @[@"#D3D3D3",@"#FA8072"];
    _isHidenAlert = YES;
    _buttonType = LQAlertViewButtonType_Two;
    _alertType = LQAlertViewType_Input;

    if(_content == nil) _content = @"设置内容";
    _contentFont = [UIFont systemFontOfSize:13.0];
    _contentColor = [UIColor lightGrayColor];
    
    _placeholder = @"请输入内容";
    _inputBackColor = [UIColor colorWithRed:241 / 255.0 green:241 / 255.0 blue:241 / 255.0 alpha:1.0];
    _inputTextColor = [UIColor blackColor];
    _inputFont = [UIFont systemFontOfSize:14.0f];
    _promptString = nil;
    _placeholders = @[@"请输入账号",@"请输入密码"];
}

@end
