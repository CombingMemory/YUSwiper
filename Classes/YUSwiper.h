//
//  YUSwiper.h
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/21.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUSwiperCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YUSwiperDelegate;

@interface YUSwiper : UIView
// pageWith 如果小于等于0 宽度等于frame.size.width
- (instancetype)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth;

@property (nonatomic, readonly) NSArray<__kindof YUSwiperCell *> *visibleCells;

@property (nonatomic, readonly) NSInteger numberOfCount;
// 当前的指引
@property (nonatomic) NSInteger currentIndex;
// 默认关闭播放
@property (nonatomic, getter=isAutoplay) BOOL autoplay;
// 自动播放时间 默认3s
@property (nonatomic) NSInteger interval;

@property (nonatomic, weak, nullable) id <YUSwiperDelegate> delegate;

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;

- (void)registerCellForClass:(nullable Class)cellClass;

- (void)reloadData;

@end

@protocol YUSwiperDelegate <UIScrollViewDelegate>

@required

- (NSInteger)numberOfCountInSwiper:(YUSwiper *)swiper;

- (void)swiper:(YUSwiper *)swiper cell:(YUSwiperCell *)cell index:(NSInteger)index;

@optional

- (void)currentIndexChange:(NSInteger)currentIndex;

- (void)swiper:(YUSwiper *)swiper didSelectItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
