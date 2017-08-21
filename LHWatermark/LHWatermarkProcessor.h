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

@interface LHWatermarkProcessor : NSObject


typedef NS_ENUM(NSUInteger,PixielType){
    PixielR,
    PixielG,
    PixielB,
};
typedef NS_ENUM(NSUInteger,FFTType){
    FFTForwardType,
    FFTBackwardType,
};

@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT in_fft_r;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT in_fft_g;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT in_fft_b;

@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT out_fft_r;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT out_fft_g;
@property (nonatomic, assign) DOUBLE_COMPLEX_SPLIT out_fft_b;

@property (nonatomic, assign)UIImage *originalImage ;
@property (nonatomic, assign)SInt32 rowStride ;
@property (nonatomic, assign)SInt32 columnStride;
@property (nonatomic, assign)NSInteger width;
@property (nonatomic, assign)NSInteger height;
@property (nonatomic, assign)NSInteger original_width;
@property (nonatomic, assign)NSInteger original_height;
@property (nonatomic, assign)unsigned char *bytePtr;


/**水印叠加参数因子*/
@property (nonatomic, assign) double  alpha;
/**种子*/
@property (nonatomic, assign) unsigned seed;

- (void)splitImage:(UIImage *)image;


/**
 对图片进行FFT逆变换
 @return 返回逆变换过后的图片
 */
-(UIImage *)ifft;

- (instancetype)initWidthImage:(UIImage *)image;
/**
 生成单通道图片
 根据PixielType来确定返回哪个通道的数据，如果direction 是正向，
 返回的是原图像的通道，反之是返回FFT变换后进行归一化的图像数据
 @param pixielType 通道名称
 @param direction 正反变换
 @return 单通道频谱图
 */
- (UIImage *)generateImageWidthPixielType:(PixielType )pixielType direction:(FFTType)direction;




/**
 生成 fft变换归一化后的三通道频谱图
 @return fft频谱图
 */
- (UIImage *)generateFFTImage;


/**
 添加水印 
 根据seed把mask的像素以一定的规则打乱，分别与fft图像进行叠加
 @param mark 水印图片，宽和高都要小于原图片
 */
- (void)addWatterMask:(UIImage* )mark;



/**
 提取水印
 @param origin 原图像的句柄类
 @param watermask 加了水印的句柄类
  @param seed 随机分布的种子
 @return 水印图片
 */
+ (UIImage *)restoreImageWidthProcess:(LHWatermarkProcessor *)origin watermask:(LHWatermarkProcessor *)watermask seed:(unsigned)seed;


/**
 生成乱序的水印矩阵
 @param image 原水印图片
 @param seed 种子
 @param width 生成目标水印宽度
 @param height 生成目标水印高度
 @return 二维乱序水印矩阵
 */
- (DOUBLE_COMPLEX_SPLIT )randomMatrixWidthImage:(UIImage *)image  seed:(unsigned)seed width:(NSInteger)width height:(NSInteger)height;


- (UIImage *)generateImageWidthMatrix:(DOUBLE_COMPLEX_SPLIT )matrix width:(NSInteger)width height:(NSInteger)height;
@end
