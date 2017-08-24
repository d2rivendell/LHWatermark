//
//  UIImage+Helper.h
//  LHWatermark
//
//  Created by Leon.Hwa on 2017/6/19.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import <UIKit/UIKit.h>
#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
@interface UIImage (Helper)

/**
 将图片进行转换，使得宽是2的N(整数)次幂, 高2的M(整数)次幂
 */
- (UIImage *)getLog2Image;


/**
 根据构造的二进制数据生成图像

 @param rawData 二进制内存块地址
 @param w 生成目标图像的宽
 @param h 生成目标图像的高
 @return 图像
 */
+ (UIImage*)imageFromRGB:(void*)rawData width:(NSUInteger)w height:(NSUInteger)h;


/**
 恢复原图像中的数字水印
 
 @param seed 种子，根据种子生成一定规律的数据逆推出原水印的排列
 @param width 打乱的数字水印的矩阵的宽
 @param height 打乱的数字水印的矩阵的高
 @param buff 数字水印内存块地址
 @return 原水印图像
 */
+ (UIImage *)restoreImageWidth:(unsigned)seed width:(NSInteger)width height:(NSInteger)height buff:(UInt32 *)buff;

/**
 返回 UInt32 *类型的图片内存地址
 */
- (UInt32 *)UInt32ImageBuff;


/**
  填充图片或者切割图片。当宽度或高度大于原图像时，超出的部分的像素进行补零填充。
 @param width 目标图片宽度
 @param height 目标图片高度
 @return 填充图片或者切割图片
 */
- (UIImage *)resizeImageWidth:(NSInteger)width height:(NSInteger)height;

/**由text生成UIImage*/
+ (UIImage *)imageWidthText:(NSString *)text font:(UIFont *)font;
@end
