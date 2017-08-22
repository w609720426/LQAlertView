//
//  LQAlertViewController.h
//  LQAlertView
//
//  Created by kingsoft on 2017/8/18.
//  Copyright © 2017年 Liuquan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LQAlertConfig;

typedef void(^LQAlertViewClickBlock)(UIView *contentView, NSInteger index);

@interface LQAlertViewController : UIViewController

/// property
@property (nonatomic, copy) LQAlertViewClickBlock clickBlock;
@property (nonatomic, strong) UIView *contentView;


/// class method
+ (instancetype)showAlertViewWithConfig:(LQAlertConfig *)alertConfig clickComplete:(LQAlertViewClickBlock)clickBlock;


@end
