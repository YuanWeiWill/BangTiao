//
//  NSDictionary+runtime.m
//  bangtiao
//
//  Created by gy on 2018/7/5.
//  Copyright © 2018年 gy. All rights reserved.
//

#import "NSDictionary+runtime.h"
#import <objc/runtime.h>

@implementation NSDictionary (runtime)

+ (void)load {

    SEL safeSel = @selector(avoidCrashDictionaryWithObjects:forKeys:count:);
    SEL unsafeSel = @selector(dictionaryWithObjects:forKeys:count:);

    Method safeMethod = class_getClassMethod(self, safeSel);
    Method unsafeMethod = class_getClassMethod(self, unsafeSel);

    // 交换方法
    method_exchangeImplementations(unsafeMethod, safeMethod);
}

+ (instancetype)avoidCrashDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{
    
    id instance = nil;
    
    @try {
        instance = [self avoidCrashDictionaryWithObjects:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        //处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self avoidCrashDictionaryWithObjects:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}

@end
