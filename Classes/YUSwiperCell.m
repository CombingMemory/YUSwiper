//
//  YUSwiperCell.m
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/23.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import "YUSwiperCell.h"
#import <Masonry/Masonry.h>

@implementation YUSwiperCell
{
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] init];
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.masksToBounds = YES;
        
        [_contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _imageView;
}

@end
