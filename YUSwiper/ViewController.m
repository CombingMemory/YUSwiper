//
//  ViewController.m
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/21.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import "ViewController.h"
#import "YUSwiper.h"
#import <Masonry/Masonry.h>

@interface ViewController ()<YUSwiperDelegate>

@property (nonatomic, strong) YUSwiper *swiper;

@property (nonatomic, strong) NSMutableArray<UIImage *> *array;

@end

@implementation ViewController

- (NSMutableArray<UIImage *> *)array{
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.swiper = [[YUSwiper alloc] init];
    self.swiper.spacing = 16;
    self.swiper.delegate = self;
    self.swiper.autoplay = YES;
    [self.view addSubview:self.swiper];
    [self.swiper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(150);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(200);
    }];
    
    
    [self.array addObject:[UIImage imageNamed:@"01.jpg"]];
    [self.array addObject:[UIImage imageNamed:@"02.jpg"]];
    [self.array addObject:[UIImage imageNamed:@"03.jpg"]];
    [self.array addObject:[UIImage imageNamed:@"04.jpg"]];
    [self.array addObject:[UIImage imageNamed:@"05.jpg"]];
//    [self.swiper reloadData];
}

- (NSInteger)numberOfCountInSwiper:(YUSwiper *)swiper{
    return self.array.count;
}

- (void)swiper:(YUSwiper *)swiper cell:(YUSwiperCell *)cell index:(NSInteger)index{
    cell.imageView.image = self.array[index];
}

- (void)currentIndexChange:(NSInteger)currentIndex{
    NSLog(@"%ld",currentIndex);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (YUSwiper *cell in self.swiper.visibleCells) {
        CGFloat offsetX = cell.frame.origin.x - scrollView.contentOffset.x;
        CGFloat multiple = fabs(offsetX) / scrollView.frame.size.width;
        CGFloat sx = 1 - multiple * 0.05;
        CGFloat sy = 1 - multiple * 0.15;
        cell.layer.transform = CATransform3DMakeScale(sx, sy, 1);
    }
}


@end
