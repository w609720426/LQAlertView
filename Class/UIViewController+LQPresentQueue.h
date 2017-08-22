//
//  UIViewController+LQPresentQueue.h
//  LQAlertView
//
//  Created by kingsoft on 2017/8/18.
//  Copyright © 2017年 Liuquan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, LQPresentType) {
    LQPresentType_LIFO,
    LQPresentType_FIFO
};


@interface UIViewController (LQPresentQueue)

/// default LIFO
- (void)lq_presentViewController:(UIViewController *)controller
                        presentCompletion:(void(^)(void))presentCompletion
                        dismissCompletion:(void(^)(void))dismissCompletion;


- (void)lq_presentViewController:(UIViewController *)controller
                                    presentType:(LQPresentType)presentType
                        presentCompletion:(void(^)(void))presentCompletion
                        dismissCompletion:(void(^)(void))dismissCompletion;

@end
