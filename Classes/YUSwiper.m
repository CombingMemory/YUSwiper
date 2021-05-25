//
//  YUSwiper.m
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/21.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import "YUSwiper.h"
#import <Masonry/Masonry.h>
#import "NSTimer+YUSwiper.h"

#define YUSWIPER_SECTION_COUNT 10000

@interface YUSwiper ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray<__kindof YUSwiperCell *> *cells;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation YUSwiper

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame pageWidth:0];
}

- (instancetype)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth{
    self = [super initWithFrame:frame];
    if (self) {
        _spacing = (frame.size.width - pageWidth) / 2;
        [self _init];
    }
    return self;
}

- (void)_init{
    self.clipsToBounds = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.scrollView];
    [self resetScrollViewConstraints];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    _numberOfCount = 0;
    _currentIndex = 0;
    _interval = 3;
    
    
    UIButton *previousBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousBtn addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousBtn];
    [previousBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(self.scrollView.mas_left);
    }];

    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.left.mas_equalTo(self.scrollView.mas_right);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self reloadData];
}

- (void)reloadData{
    if (self.scrollView.frame.size.width == 0) return;
    if ([_delegate respondsToSelector:@selector(numberOfCountInSwiper:)]) {
        _numberOfCount = [_delegate numberOfCountInSwiper:self];
    }
    if (0 != self.numberOfCount) {
        // 并未注册过cell 注册默认cell
        if (0 == self.cells.count) {
            [self registerCellForClass:[YUSwiperCell class]];
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * _numberOfCount * YUSWIPER_SECTION_COUNT, self.scrollView.frame.size.height);
        [self moveToCenter];
        
        [self checkAutoplay];
    }
}

- (void)resetScrollViewConstraints{
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.spacing);
        make.right.mas_equalTo(-self.spacing);
        make.top.bottom.mas_equalTo(0);
    }];
}

- (void)registerCellForClass:(Class)cellClass{
    for (YUSwiperCell *cell in self.cells) {
        [cell removeFromSuperview];
    }
    [self.cells removeAllObjects];
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = self.scrollView.bounds.size.height;
    for (int i = 0; i < 3; i++) {
        YUSwiperCell *cell = [[cellClass alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        [self.scrollView addSubview:cell];
        [self.cells addObject:cell];
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickItem:)]];
    }
}

- (void)cellReuseWithOffsetX:(float)offsetX{
    offsetX += self.scrollView.frame.size.width / 2;
    NSInteger currentIndex = (NSInteger)(offsetX / self.scrollView.frame.size.width) % self.numberOfCount;
    currentIndex = (int)[self checkIndexOutOfBounds:currentIndex];
    if (currentIndex != _currentIndex) {
        // 将要消失不显示的cell
        YUSwiperCell *pre_cell = [self getCellAtIndex:_currentIndex];
        if ([_delegate respondsToSelector:@selector(swiper:willDisappearCell:atIndex:)]) {
            [_delegate swiper:self willDisappearCell:pre_cell atIndex:_currentIndex];
        }
        // 最新的index
        _currentIndex = currentIndex;
        if ([_delegate respondsToSelector:@selector(currentIndexChange:)]) {
            [_delegate currentIndexChange:_currentIndex];
        }
        // 当前显示的cell
        YUSwiperCell *current_cell = [self getCellAtIndex:_currentIndex];
        if ([_delegate respondsToSelector:@selector(swiper:currentDisplayCell:atIndex:)]) {
            [_delegate swiper:self currentDisplayCell:current_cell atIndex:_currentIndex];
        }
        
    }
    
    
    for (YUSwiperCell *cell in self.cells) {
        CGFloat cellX = cell.frame.origin.x;
        CGFloat difference = offsetX - cellX;
        CGRect cellFrame = cell.frame;
        CGFloat x = self.scrollView.frame.size.width * 3;
        if (difference > self.scrollView.frame.size.width * 1.7) {
            if (cellFrame.origin.x + x < self.scrollView.contentSize.width) {
                cellFrame.origin.x += x;
                cell.frame = cellFrame;
                NSInteger index = (NSInteger)cellFrame.origin.x / (NSInteger)self.scrollView.frame.size.width % self.numberOfCount;
                [self swiperForCell:cell atIndex:index];
            }
        }
        if (difference < -self.scrollView.frame.size.width * 1.3) {
            if (cellFrame.origin.x - x >= 0) {
                cellFrame.origin.x -= x;
                cell.frame = cellFrame;
                NSInteger index = (NSInteger)cellFrame.origin.x / (NSInteger)self.scrollView.frame.size.width % self.numberOfCount;
                [self swiperForCell:cell atIndex:index];
            }
        }
    }
    
    // 检查是否已经快移动到边缘了。移动到中心
    if (offsetX < self.scrollView.frame.size.width * self.numberOfCount * 100 || offsetX > self.scrollView.contentSize.width - self.scrollView.frame.size.width * self.numberOfCount * 100) {
        [self moveToCenter];
    }
}

- (void)moveToCenter{
    // 移动到中间
    [self.cells enumerateObjectsUsingBlock:^(__kindof YUSwiperCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        // 重置大小
        CGRect cellFrame = self.scrollView.bounds;
        cellFrame.origin.x = (self.numberOfCount * (YUSWIPER_SECTION_COUNT / 2) + self.currentIndex + (idx - 1)) * self.scrollView.frame.size.width;
        cell.frame = cellFrame;
        
        NSInteger index = (self.currentIndex + (idx - 1) + self.numberOfCount) % self.numberOfCount;
        
        [self swiperForCell:cell atIndex:index];
        
        if (index == self.currentIndex) {
            if ([_delegate respondsToSelector:@selector(swiper:currentDisplayCell:atIndex:)]) {
                [_delegate swiper:self currentDisplayCell:cell atIndex:index];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(swiper:willDisappearCell:atIndex:)]) {
                [_delegate swiper:self willDisappearCell:cell atIndex:index];
            }
        }
        
    }];
    CGFloat offsetX = (self.numberOfCount * (YUSWIPER_SECTION_COUNT / 2) + self.currentIndex) * self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)swiperForCell:(YUSwiperCell *)cell atIndex:(NSInteger)index{
    cell.index = index;
    if ([_delegate respondsToSelector:@selector(swiper:cell:index:)]) {
        [_delegate swiper:self cell:cell index:index];
    }
}

- (YUSwiperCell *)getCellAtIndex:(NSInteger)index{
    YUSwiperCell *cell = nil;
    for (YUSwiperCell *obj in self.cells) {
        if (index == obj.index) {
            cell = obj;
            break;;
        }
    }
    return cell;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated {
    if (!_numberOfCount) return;
    index = [self checkIndexOutOfBounds:index];
    if (_currentIndex == index) return;
    [self moveToCenter];
    NSInteger currentIndex = (index + self.numberOfCount) % self.numberOfCount;
    CGFloat moveOffsetX = (currentIndex - _currentIndex) * self.scrollView.frame.size.width;
    _currentIndex = currentIndex;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + moveOffsetX, 0) animated:animated];
}

- (NSInteger)checkIndexOutOfBounds:(NSInteger)index{
    // 防止越界
    if (index < 0 || 0 == self.numberOfCount) {
        return 0;
    }
    if (index > self.numberOfCount - 1) {
        return self.numberOfCount - 1;
    }
    return index;
}


- (NSArray<__kindof YUSwiperCell *> *)visibleCells{
    return [NSArray arrayWithArray:self.cells];
}

- (void)setSpacing:(float)spacing{
    spacing = spacing < 0?0:spacing;
    if (_spacing == spacing) return;
    _spacing = spacing;
    // 清除timer
    [self cleanTimer];
    [self resetScrollViewConstraints];
    [self reloadData];
}

- (void)setInterval:(NSInteger)interval{
    if (_interval == interval) return;
    _interval = interval;
    // 清除timer
    [self cleanTimer];
    [self checkAutoplay];
}

- (void)setAutoplay:(BOOL)autoplay {
    if (_autoplay == autoplay) return;
    _autoplay = autoplay;
    [self checkAutoplay];
}

/// 检查是否可以开始自动轮博
- (void)checkAutoplay{
    if (self.numberOfCount && self.isAutoplay) {
        [self startTimer];
    }else{
        [self stopTimer];
    }
}

/// 自动轮播
- (void)autoplay{
    [self next:nil];
}

- (void)startTimer{
    NSTimeInterval time_interval = [[NSDate date] timeIntervalSince1970] + self.interval;
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSince1970:time_interval]];
}

/// 暂停timer
- (void)stopTimer{
    [_timer setFireDate:[NSDate distantFuture]];
}

// 下一个
- (void)next:(UIButton *)btn{
    if (btn) {
        btn.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btn.enabled = YES;
            [self checkAutoplay];
        });
        [self stopTimer];
    }
    CGFloat offsetX = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

// 上一个
- (void)previous:(UIButton *)btn{
    if (btn) {
        btn.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btn.enabled = YES;
            [self checkAutoplay];
        });
        [self stopTimer];
    }
    CGFloat offsetX = self.scrollView.contentOffset.x - self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)clickItem:(UITapGestureRecognizer *)tap{
    if ([_delegate respondsToSelector:@selector(swiper:didSelectItemAtIndex:)]) {
        [_delegate swiper:self didSelectItemAtIndex:self.currentIndex];
    }
}

#pragma mark lazy
- (NSMutableArray<__kindof YUSwiperCell *> *)cells{
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (NSTimer *)timer{
    if (!_timer) {
        __weak __typeof(self)weakSelf = self;
        _timer = [NSTimer yuSwiper_timerWithTimeInterval:self.interval repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf autoplay];
        }];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (void)cleanTimer{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 手指刚开始的时候停止timer
    [self stopTimer];
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self cellReuseWithOffsetX:scrollView.contentOffset.x];
    if ([_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if ([_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self checkAutoplay];
    
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark willMoveToWindow
- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        if (0 != self.numberOfCount) {
            [self moveToCenter];
            [self checkAutoplay];
        }
    }else{
        [self stopTimer];
    }
}


#pragma mark dealloc
- (void)dealloc{
    [self cleanTimer];
}

@end
