//
//  LHConfig.m
//  LHWatermarkExample
//
//  Created by Leon.Hwa on 2017/8/23.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "LHConfig.h"

@implementation LHConfig
- (instancetype)initWidthAlpha:(NSUInteger)alpha seed:(unsigned)seed font:(UIFont *)font{
    self = [super init];
    if (self) {
        _alpha = alpha;
        _seed = seed;
        _font = font;
    }
    return self;
}
+ (instancetype)defaultConfig{
    return [[LHConfig alloc] initWidthAlpha:3 seed:1024 font:[UIFont systemFontOfSize:40]];
}
@end
