//
//  YUSwiperCell.m
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/23.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import "YUSwiperCell.h"

@implementation YUSwiperCell

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 8;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

@end
