//
//  NSArray+runtime.m
//  bangtiao
//
//  Created by gy on 2018/7/5.
//  Copyright © 2018年 gy. All rights reserved.
//

#import "NSArray+runtime.h"
#import <objc/runtime.h>

@implementation NSArray (runtime)

+ (void)load {
    // 选择器
    SEL safeSel = @selector(safeObjectAtIndex:);
    SEL unsafeSel = @selector(objectAtIndex:);
    
    Class class = NSClassFromString(@"__NSArrayI");
    // 方法
    Method safeMethod = class_getInstanceMethod(class, safeSel);
    Method unsafeMethod = class_getInstanceMethod(class, unsafeSel);
    
    // 交换方法
    method_exchangeImplementations(unsafeMethod, safeMethod);
}


- (id)safeObjectAtIndex:(NSUInteger)index {

    if (index > (self.count - 1)) {
        NSAssert(YES, @"数组越界了");
        return nil;
    }else {
        return [self safeObjectAtIndex:index];
    }
}

@end
