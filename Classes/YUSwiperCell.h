//
//  YUSwiperCell.h
//  YUSwiper
//
//  Created by 捋忆 on 2020/5/23.
//  Copyright © 2020 捋忆. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YUSwiperCell : UIView

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
