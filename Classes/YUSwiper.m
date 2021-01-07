//
//  YUSwiper.m
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/21.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import "YUSwiper.h"

@interface YUSwiper ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, readonly) NSMutableArray<__kindof YUSwiperCell *> *cells;

@property (nonatomic, readonly) CGFloat pageWidth;

@end

@implementation YUSwiper

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame pageWidth:0];
}

- (instancetype)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth{
    self = [super initWithFrame:frame];
    if (self) {
        _pageWidth = (int)(pageWidth <= 0?frame.size.width:pageWidth);
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((frame.size.width - self.pageWidth) / 2, 0, self.pageWidth, frame.size.height)];
        [self addSubview:self.scrollView];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        _numberOfCount = 0;
        _currentIndex = 0;
        _interval = 3;
        _cells = [NSMutableArray array];
        [self registerCellForClass:[YUSwiperCell class]];
        if (self.pageWidth != frame.size.width) {
            UIButton *previousBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            previousBtn.frame = CGRectMake(0, 0, (frame.size.width - self.pageWidth) / 2, frame.size.height);
            [self addSubview:previousBtn];
            [previousBtn addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            nextBtn.frame = CGRectMake(frame.size.width - (frame.size.width - self.pageWidth) / 2, 0, (frame.size.width - self.pageWidth) / 2, frame.size.height);
            [self addSubview:nextBtn];
            [nextBtn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
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

- (void)setDelegate:(id<YUSwiperDelegate>)delegate{
    _delegate = delegate;
    [self reloadData];
}

- (void)reloadData{
    if ([_delegate respondsToSelector:@selector(numberOfCountInSwiper:)]) {
        _numberOfCount = [_delegate numberOfCountInSwiper:self];
    }
    if (_numberOfCount) {
        self.scrollView.contentSize = CGSizeMake(self.pageWidth * _numberOfCount * 10000, self.scrollView.frame.size.height);
        [self moveToCenter];
        [self startAutoplay];
    }
}

- (void)moveToCenter{
    // 移动到中间
    for (int i = 0; i < 3; i++) {
        YUSwiperCell *cell = self.cells[i];
        cell.layer.transform = CATransform3DIdentity;
        CGRect cellFrame = self.scrollView.bounds;
        cellFrame.origin.x = (self.numberOfCount * 5000 + self.currentIndex + (i - 1)) * self.pageWidth;
        cell.frame = cellFrame;
        if ([_delegate respondsToSelector:@selector(swiper:cell:index:)]) {
            [_delegate swiper:self cell:cell index:(self.currentIndex + (i - 1) + self.numberOfCount) % self.numberOfCount];
        }
    }
    [self.scrollView setContentOffset:CGPointMake((self.numberOfCount * 5000 + self.currentIndex) * self.pageWidth, 0)];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated {
    if (!_numberOfCount) return;
    if (index < 0) return;
    if (_currentIndex == index) return;
    [self moveToCenter];
    NSInteger currentIndex = (index + self.numberOfCount) % self.numberOfCount;
    CGFloat moveOffsetX = (currentIndex - _currentIndex) * self.pageWidth;
    _currentIndex = currentIndex;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + moveOffsetX, 0) animated:animated];
}

- (NSArray<__kindof YUSwiperCell *> *)visibleCells{
    return [NSArray arrayWithArray:_cells];
}

- (void)setAutoplay:(BOOL)autoplay{
    _autoplay = autoplay;
    [self startAutoplay];
}

- (void)startAutoplay{
    [self cancelAutoplay];
    if (self.numberOfCount && self.isAutoplay) {
        [self performSelector:@selector(autoplay) withObject:nil afterDelay:self.interval];
    }
}

- (void)autoplay{
    [self next:nil];
    [self performSelector:@selector(autoplay) withObject:nil afterDelay:self.interval];
}

- (void)cancelAutoplay{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoplay) object:nil];
}

// 下一个
- (void)next:(UIButton *)btn{
    if (btn) {
        btn.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btn.enabled = YES;
            [self startAutoplay];
        });
        [self cancelAutoplay];
    }
    CGFloat offsetX = self.scrollView.contentOffset.x + self.pageWidth;
    if (offsetX > self.scrollView.contentSize.width - self.pageWidth * self.numberOfCount * 100) {
        [self moveToCenter];
    }
    NSInteger index = (NSInteger)(offsetX / self.pageWidth);
    NSInteger remainder = (NSInteger)offsetX % (NSInteger)self.pageWidth;
    if (remainder) {
        index++;
    }
    [self.scrollView setContentOffset:CGPointMake(index * self.pageWidth, 0) animated:YES];
}

// 上一个
- (void)previous:(UIButton *)btn{
    if (btn) {
        btn.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btn.enabled = YES;
            [self startAutoplay];
        });
        [self cancelAutoplay];
    }
    CGFloat offsetX = self.scrollView.contentOffset.x - self.pageWidth;
    if (offsetX < self.pageWidth * self.numberOfCount * 100) {
        [self moveToCenter];
    }
    NSInteger index = (NSInteger)(offsetX / self.pageWidth);
    NSInteger remainder = (NSInteger)offsetX % (NSInteger)self.pageWidth;
    if (remainder) {
        index--;
    }
    [self.scrollView setContentOffset:CGPointMake(index * self.pageWidth, 0) animated:YES];
}

- (void)clickItem:(UITapGestureRecognizer *)tap{
    if ([_delegate respondsToSelector:@selector(swiper:didSelectItemAtIndex:)]) {
        [_delegate swiper:self didSelectItemAtIndex:self.currentIndex];
    }
}

#pragma mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.isAutoplay) {
        [self cancelAutoplay];
    }
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger currentIndex = (NSInteger)(offsetX / self.pageWidth) % self.numberOfCount;
    if (currentIndex != _currentIndex) {
        _currentIndex = currentIndex;
        if ([_delegate respondsToSelector:@selector(currentIndexChange:)]) {
            [_delegate currentIndexChange:_currentIndex];
        }
    }
    for (YUSwiperCell *cell in self.cells) {
        CGFloat cellX = cell.frame.origin.x;
        CGFloat difference = offsetX - cellX;
        CGRect cellFrame = cell.frame;
        CGFloat x = self.pageWidth * 3;
        if (difference > self.pageWidth * 1.5) {
            if (cellFrame.origin.x + x < scrollView.contentSize.width) {
                cellFrame.origin.x += x;
                cell.frame = cellFrame;
                if ([_delegate respondsToSelector:@selector(swiper:cell:index:)]) {
                    NSInteger index = (NSInteger)cellFrame.origin.x / (NSInteger)self.pageWidth % self.numberOfCount;
                    [_delegate swiper:self cell:cell index:index];
                }
            }
        }
        if (difference < -self.pageWidth*1.5) {
            if (cellFrame.origin.x - x >= 0) {
                cellFrame.origin.x -= x;
                cell.frame = cellFrame;
                if ([_delegate respondsToSelector:@selector(swiper:cell:index:)]) {
                    NSInteger index = (NSInteger)cellFrame.origin.x / (NSInteger)self.pageWidth % self.numberOfCount;
                    [_delegate swiper:self cell:cell index:index];
                }
            }
        }
    }
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
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX < self.pageWidth * self.numberOfCount * 100 || offsetX > self.scrollView.contentSize.width - self.pageWidth * self.numberOfCount * 100) {
        [self moveToCenter];
    }
    [self startAutoplay];
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:scrollView];
    }
}


@end
