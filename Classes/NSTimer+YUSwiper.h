//
//  NSTimer+YUSwiper.h
//  NewTest
//
//  Created by 捋忆 on 2021/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (YUSwiper)

+ (NSTimer *)yuSwiper_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
