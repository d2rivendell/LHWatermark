//
//  LHConfig.h
//  LHWatermarkExample
//
//  Created by Leon.Hwa on 2017/8/23.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHConfig : NSObject
/**
 水印叠加参数因子
 */
@property (nonatomic, assign) NSUInteger  alpha;
/**
 种子
 */
@property (nonatomic, assign) unsigned seed;
/**
 水印文字的字体大小
 */
@property (nonatomic, assign) UIFont  *font;


- (instancetype)initWithAlpha:(NSUInteger)alpha seed:(unsigned)seed font:(UIFont *)font;


+ (instancetype)defaultConfig;
@end
