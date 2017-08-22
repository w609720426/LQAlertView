//
//  UIViewController+LQPresentQueue.m
//  LQAlertView
//
//  Created by kingsoft on 2017/8/18.
//  Copyright © 2017年 Liuquan. All rights reserved.
//

#import "UIViewController+LQPresentQueue.h"
#import <objc/runtime.h>


@implementation UIViewController (LQPresentQueue)

+ (void)load {
    SEL oldSEL = @selector(viewDidDisappear:);
    SEL newSEL = @selector(lq_viewDidDisappear:);
    Method oldMethod = class_getInstanceMethod([self class], oldSEL);
    Method newMethod = class_getInstanceMethod([self class], newSEL);
    BOOL didAddMethod = class_addMethod(self, oldSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        class_replaceMethod(self, newSEL, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

- (void)lq_viewDidDisappear:(BOOL)animated {
    [self lq_viewDidDisappear:animated];
    if ([self getDeallocCompletion] && ![self tempDismissing]) {
        [self getDeallocCompletion]();
    }
}

/// 存储多个Controller
- (NSMutableArray *)getStackControllers {
    static NSMutableArray *stackControllers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stackControllers = [NSMutableArray array];
    });
    return stackControllers;
}

- (NSOperationQueue *)getOperationQueue {
    static NSOperationQueue *operationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
    });
    return operationQueue;
}

#pragma mark - 动态绑定
/// present
- (void)setPresentCompletion:(void(^)(void))completion {
    objc_setAssociatedObject(self, @selector(getPresentCompletion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void(^)(void))getPresentCompletion {
   return  objc_getAssociatedObject(self, _cmd);
}

/// dissmiss
- (void)setDismissCompletion:(void(^)(void))completion {
    objc_setAssociatedObject(self, @selector(getDismissCompletion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void(^)(void))getDismissCompletion {
    return objc_getAssociatedObject(self, _cmd);
}

/// 是否正在关闭
- (void)setDismissing:(BOOL)dismissing {
    objc_setAssociatedObject(self, @selector(isDismissing), @(dismissing), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)isDismissing {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return [num boolValue];
}

/// 是否是临时关闭
- (void)setTempDismissing:(BOOL)tmpDismissing {
    objc_setAssociatedObject(self, @selector(tempDismissing),@(tmpDismissing), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)tempDismissing {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return [num boolValue];
}

/// 真正销毁
- (void)setDeallocCompletion:(void(^)(void))completion {
    objc_setAssociatedObject(self, @selector(getDeallocCompletion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void(^)(void))getDeallocCompletion {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCurrentPresentType:(LQPresentType)presentType {
    objc_setAssociatedObject(self, @selector(getCurrentPresentType), @(presentType), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (LQPresentType)getCurrentPresentType {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return [num integerValue];
}


#pragma mark - present
- (void)lq_presentViewController:(UIViewController *)controller presentCompletion:(void (^)(void))presentCompletion
               dismissCompletion:(void (^)(void))dismissCompletion {
    [self lq_presentViewController:controller presentType:LQPresentType_LIFO presentCompletion:presentCompletion dismissCompletion:dismissCompletion];
}


- (void)lq_presentViewController:(UIViewController *)controller presentType:(LQPresentType)presentType presentCompletion:(void (^)(void))presentCompletion dismissCompletion:(void (^)(void))dismissCompletion {
    if (presentType == LQPresentType_LIFO) {
        [self lifoPresentController:controller presentCompletion:presentCompletion dismissCompletion:dismissCompletion];
    } else {
        [self fifoPresentViewController:controller presentCompletion:presentCompletion dismissCompletion:dismissCompletion];
    }
}

#pragma mark - LIFO
- (void)lifoPresentController:(UIViewController *)controller presentCompletion:(void (^)(void))presentCompletion
            dismissCompletion:(void (^)(void))dismissCompletion {
    dispatch_semaphore_t semaphare = dispatch_semaphore_create(0);
    NSMutableArray *stackControllers = [self getStackControllers];
    if (![stackControllers containsObject:controller]) {
        [stackControllers addObject:controller];
    }
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __weak typeof(self)weakself = controller;
        [controller setPresentCompletion:presentCompletion];
        [controller setDismissCompletion:dismissCompletion];
        [controller setDeallocCompletion:^{
            if (dismissCompletion) {
                dismissCompletion();
            }
            [weakself setDismissing:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself setDismissing:NO];
                if (stackControllers.lastObject == weakself) {
                    [stackControllers removeObject:weakself];
                    if (stackControllers.count > 0) {
                        UIViewController *preController = [stackControllers lastObject];
                        [self lifoPresentController:preController presentCompletion:[preController getPresentCompletion] dismissCompletion:[preController getDismissCompletion]];
                    }
                } else {
                    NSUInteger index = [stackControllers indexOfObject:weakself];
                    [stackControllers removeObject:weakself];
                    
                    NSArray *nextControllers = [stackControllers objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, stackControllers.count - index)]];
                    for (UIViewController *nextController in nextControllers) {
    
                        [self lifoPresentController:nextController presentCompletion:[nextController getPresentCompletion] dismissCompletion:[nextController getDismissCompletion]];
                    }
                }
            });
        }];

        if (stackControllers.count > 1) {
            for (UIViewController *preController in stackControllers) {
                if ([preController isDismissing]) {return ;}
            }
        }
        
        /// 当上一个关闭后弹出下一个
       dispatch_async(dispatch_get_main_queue(), ^{
           if (self.presentedViewController) {
               [self.presentedViewController tempDismissViewControllerAnimated:YES completion:^{
                   [self presentViewController:controller animated:YES completion:^{
                       dispatch_semaphore_signal(semaphare);
                   }];
               }];
           } else {
               [self presentViewController:controller animated:YES completion:^{
                   dispatch_semaphore_signal(semaphare);
                   if (presentCompletion) {
                       presentCompletion();
                   }
               }];
           }
       });
        dispatch_semaphore_wait(semaphare, DISPATCH_TIME_FOREVER);
    }];
    if ([self getOperationQueue].operations.lastObject) {
        [operation addDependency:[self getOperationQueue].operations.lastObject];
    }
    [[self getOperationQueue] addOperation:operation];
}

- (void)fifoPresentViewController:(UIViewController *)controller presentCompletion:(void (^)(void))presentCompletion dismissCompletion:(void (^)(void))dismissCompletion {
    dispatch_semaphore_t semaphare = dispatch_semaphore_create(0);
    
    __weak typeof(self)weakself = controller;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [controller setDeallocCompletion:^{
            if (dismissCompletion) {dismissCompletion();}
            dispatch_semaphore_signal(semaphare);
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:weakself animated:YES completion:nil];
        });
        dispatch_semaphore_wait(semaphare, DISPATCH_TIME_FOREVER);
    }];
    if ([self getOperationQueue].operations.lastObject) {
        [operation addDependency:[self getOperationQueue].operations.lastObject];
    }
    [[self getOperationQueue] addOperation:operation];
}

#pragma mark - private
- (void)tempDismissViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion {
    [self setTempDismissing:YES];
    [self dismissViewControllerAnimated:animated completion:^{
        [self setTempDismissing:NO];
        if (completion) {
            completion();
        }
    }];
}


@end
