//
//  UIImage+Helper.m
//  LHWatermark
//
//  Created by Leon.Hwa on 2017/6/19.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)
- (UIImage *)getLog2Image{

    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat nImageW = [self normalize:width];
    CGFloat nImageH = [self normalize:height];
    if(width != nImageW || height != nImageH){
       return  [self resizeImageWidth:nImageW height:nImageH];
    }
    return self;
}
- (NSInteger)normalize:(CGFloat)length{
    //ceil 有小数进1
    return 1 << (NSInteger)(ceil(log2(length)));
}



- (UIImage *)resizeImageWidth:(NSInteger)width height:(NSInteger)height
{
    NSInteger originW = self.size.width;
    NSInteger originH = self.size.height;
    UInt32 * imagePixels = [self UInt32ImageBuff];
    //当前尺寸与目标尺寸大小一致
    if(width ==  originW && height == originH){
       return self;
    }
     UInt32 * currentPixel = imagePixels;
     UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * height * width);
    // 还原
    if(width < originW && height < originH){
        for (NSInteger j = 0; j < height; j++) {
            for (NSInteger i = 0; i < width; i++) {
                UInt32 color = *currentPixel;
                NSInteger index = j * width + i;
                    imageBuffer[index] = color;
                    currentPixel++;
            }
            currentPixel += originW - width;
        }
    }else{
        // 补零
        for (NSInteger j = 0; j < height; j++) {
            for (NSInteger i = 0; i < width; i++) {
               
                NSInteger index = j * width + i;
                if(j >= originH || i >= originW){
                    // set to 0
                    imageBuffer[index] = 0x000000;
                }else{
                    UInt32 color = *currentPixel;
                    imageBuffer[index] = color;
                    currentPixel++;
                }
            }
        }
    }
    free(imagePixels);
    return [UIImage imageFromRGB:imageBuffer width:width height:height];
}


+ (UIImage *)restoreImageWidth:(unsigned)seed width:(NSInteger)width height:(NSInteger)height buff:(UInt32 *)buff{
    NSInteger N = width * height;
    //random
    srand(seed);
    int *order = (int *)malloc(sizeof(int) * N/2);
    int *random = (int *)malloc(sizeof(int) * N/2);
    memset(random, 0, N/2);
    for (NSInteger i = 0;i < N/2;i++) {
        order[i] = (int)i;
    }
    
    NSInteger count = N/2;
    // 在 0...count个数  中抽取第n个 取出a[n] 把 a[count - 1]的值转到a[n]上
    while (count > 0) {
        NSInteger index = rand() % (count);
        random[N/2 - count] = order[index];
        order[index] = order[count-1];
        count--;
    }
    
      int *realQueue = (int *)malloc(sizeof(int) * N/2);
     memset(realQueue, 0, N/2);
    // 数组里面的数据要和下标换位置 例如: a[i] = j ===> a[j] = i
    for (int i = 0;i < N/2;i++) {
        realQueue[random[i]] = i;
    }
    
    UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * N);
   UInt32 * currentPixel = buff;
    for (NSInteger i = 0; i < N/2; i++) {
            UInt32 color = *currentPixel;
            imageBuffer[realQueue[i]] = RGBAMake(R(color), G(color), B(color), 255);
            imageBuffer[N - realQueue[i] - 1] = RGBAMake(R(color), G(color), B(color), 255);
            currentPixel++;
    
    }
     free(order);
     free(realQueue);
     free(random);
     free(buff);
    return [UIImage imageFromRGB:imageBuffer width:width height:height];
}

+ (UIImage*)imageFromRGB:(void*)rawData width:(NSUInteger)w height:(NSUInteger)h
{
    const size_t bufferLength = w * h * sizeof(UInt32);
    NSData *data = [NSData dataWithBytes:rawData length:bufferLength];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(w,
                                        h,
                                        8,
                                        sizeof(UInt32) * 8,
                                        w * sizeof(UInt32),
                                        colorSpace,
                                        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault 
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    return finalImage;
}
- (UInt32 *)UInt32ImageBuff{
    CGImageRef cgImage = [self CGImage];
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * self.size.width;
    NSUInteger bitsPerComponent = 8;
    UInt32 * imagePixels;
    imagePixels = (UInt32 *) calloc(self.size.height * self.size.width, sizeof(UInt32));
    CGColorSpaceRef colorSpace =     CGColorSpaceCreateDeviceRGB();
    CGContextRef context =     CGBitmapContextCreate(imagePixels,
                                                     self.size.width, self.size.height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), cgImage);
    return imagePixels;
}

+ (UIImage *)imageWidthText:(NSString *)text font:(UIFont *)font{
    UILabel *lb = [[UILabel alloc] init];
    lb.textColor = [UIColor blackColor];
    lb.backgroundColor = [UIColor whiteColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.backgroundColor = [UIColor whiteColor];
    lb.adjustsFontSizeToFitWidth = YES;
    lb.text = text;
    lb.font = font;
    lb.bounds = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return  [UIImage imageWithView:lb];
}
+ (UIImage*) imageWithView:(UIView*) view;
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}
@end
