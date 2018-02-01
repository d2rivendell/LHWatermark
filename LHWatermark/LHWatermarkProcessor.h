//
//  LHWatermarkProcessor.h
//  LHWatermark
//
//  Created by Leon.Hwa on 2017/6/19.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

typedef NS_ENUM(NSUInteger,PixielType){
    PixielR,
    PixielG,
    PixielB,
};
typedef NS_ENUM(NSUInteger,FFTType){
    FFTForwardType,
    FFTBackwardType,
};

@class LHConfig;
@interface LHWatermarkProcessor : NSObject

@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT in_fft_r;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT in_fft_g;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT in_fft_b;

@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT out_fft_r;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT out_fft_g;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT out_fft_b;
/**扩展后图像的宽度*/
@property (nonatomic, assign)NSInteger width;
/**扩展后图像的高度*/
@property (nonatomic, assign)NSInteger height;



@property (nonatomic, strong) LHConfig *config;


/**
  把文字转成Image, 把文字Image和频域图片进行叠加，再进行二维FFT逆变换，返回嵌入文字水印后的图片

 */
- (void)addMarkText:(NSString *)markText result:(void(^)(UIImage *watermarkImage))result;

/**
 把水印和频域图片进行叠加，再进行二维FFT变换，返回嵌入文字水印后的图片
 
 */
- (void)addMarkImage:(UIImage *)markImage result:(void(^)(UIImage *watermarkImage))result;

/**
 对图片进行二维FFT逆变换
 */
-(UIImage *)ifft;

- (instancetype)initWithImage:(UIImage *)image config:(LHConfig *)config;
/**
 生成单通道图片
 根据PixielType来确定返回哪个通道的数据，如果direction 是正向，
 返回的是原图像的通道，反之是返回FFT变换后进行归一化的图像数据
 @param pixielType 通道名称
 @param direction 正反变换
 @return 单通道频谱图
 */
- (UIImage *)generateImageWithPixielType:(PixielType )pixielType direction:(FFTType)direction;




/**
 生成 fft变换归一化后的三通道频谱图
 */
- (UIImage *)generateFFTImage;



/**
  提取水印

 @param originImage 原始图片
 @param watermarkImage 加了水印的图片
 @param config 配置
 @param result 生成含有水印文字的图片
 */
+ (void)restoreImageWithOriginImage:(UIImage *)originImage watermarkImage:(UIImage *)watermarkImage config:(LHConfig *)config result:(void(^)(UIImage *markImage))result;

/**
 生成乱序的水印矩阵
 @param image 原水印图片
 @param seed 种子
 @param width 生成目标水印宽度
 @param height 生成目标水印高度
 @return 二维乱序水印矩阵
 */
- (DOUBLE_COMPLEX_SPLIT )randomMatrixWithImage:(UIImage *)image  seed:(unsigned)seed width:(NSInteger)width height:(NSInteger)height;


/**
 根据矩阵数据生成图像，矩阵数据满足0～255
 */
- (UIImage *)generateImageWithMatrix:(DOUBLE_COMPLEX_SPLIT )matrix width:(NSInteger)width height:(NSInteger)height;

@end
