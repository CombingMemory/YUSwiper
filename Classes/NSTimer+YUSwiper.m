//
//  NSTimer+YUSwiper.m
//  NewTest
//
//  Created by 捋忆 on 2021/4/9.
//

#import "NSTimer+YUSwiper.h"

@implementation NSTimer (YUSwiper)

+ (NSTimer *)yuSwiper_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull))block{
    NSTimer *timer = [self timerWithTimeInterval:interval target:self selector:@selector(yuSwiperTimerAction:) userInfo:[block copy] repeats:repeats];
    return timer;
}

+ (void)yuSwiperTimerAction:(NSTimer *)timer{
    void (^timerBlock)(NSTimer *timer) = timer.userInfo;
    if (timerBlock) {
        timerBlock(timer);
    }
}

@end
