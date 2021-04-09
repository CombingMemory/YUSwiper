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
/// 初始化方法
/// @param frame 控件大小
/// @param pageWidth 整页滑动的宽度
- (instancetype)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth;
/// 左右两边的间距
@property (nonatomic, assign) float spacing;
/// 可见的Cell
@property (nonatomic, readonly) NSArray<__kindof YUSwiperCell *> *visibleCells;
/// 总数
@property (nonatomic, readonly) NSInteger numberOfCount;
/// 自动轮播 默认：NO
@property (nonatomic, getter=isAutoplay) BOOL autoplay;
/// 自动轮播时间 默认3s
@property (nonatomic) NSInteger interval;
/// 代理<YUSwiperDelegate>
@property (nonatomic, weak, nullable) id <YUSwiperDelegate> delegate;
/// 设置当前指引
/// @param index 指引
/// @param animated 是否开启动画
- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;
/// 当前的指引
@property (nonatomic) NSInteger currentIndex;
/// 注册Cell
/// @param cellClass 需要注册cell的类名称
- (void)registerCellForClass:(nullable Class)cellClass;
/// 重新加载数据
- (void)reloadData;

@end





//-----------------------------------------------------------






@protocol YUSwiperDelegate <UIScrollViewDelegate>

@required

- (NSInteger)numberOfCountInSwiper:(YUSwiper *)swiper;

- (void)swiper:(YUSwiper *)swiper cell:(YUSwiperCell *)cell index:(NSInteger)index;

@optional

- (void)currentIndexChange:(NSInteger)currentIndex;

- (void)swiper:(YUSwiper *)swiper didSelectItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
