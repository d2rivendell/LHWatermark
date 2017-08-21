//
//  LHWatermarkProcessor.m
//  LHWatermark
//
//  Created by Leon.Hwa on 2017/6/19.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "LHWatermarkProcessor.h"
#import "UIImage+Helper.h"

@interface LHWatermarkProcessor()

@end

@implementation LHWatermarkProcessor


- (instancetype)initWidthImage:(UIImage *)image
{
    self = [super init];
    if (self) {
             _alpha = 1;
            [self splitImage:image];
            [self fftImage];
    }
    return self;
}

- (void)splitImage:(UIImage *)image{
    _original_width = image.size.width;
    _original_height = image.size.height;
       image = [image getLog2Image];

        CGImageRef cgImage = [image CGImage];
          _width  =   CGImageGetWidth(cgImage);
          _height =   CGImageGetHeight(cgImage);
    NSInteger numElements = _width * _height;
    
    _in_fft_r.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _in_fft_r.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _in_fft_g.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _in_fft_g.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _in_fft_b.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _in_fft_b.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
 
    
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * _width;
        NSUInteger bitsPerComponent = 8;
        UInt32 * imagePixels;
        imagePixels = (UInt32 *) calloc(_height * _width, sizeof(UInt32));
        CGColorSpaceRef colorSpace =     CGColorSpaceCreateDeviceRGB();
        CGContextRef context =     CGBitmapContextCreate(imagePixels,
                                                         _width, _height,
                                                         bitsPerComponent,
                                                         bytesPerRow,
                                                         colorSpace,
                                                         kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), cgImage);
        UInt32 * currentPixel = imagePixels;

        for (NSInteger j = 0; j < _height; j++) {
            for (NSInteger i = 0; i < _width; i++) {
                UInt32 color = *currentPixel;
                _in_fft_r.realp[j * _width + i] = R(color);
                _in_fft_r.imagp[j * _width + i] = 0;
                
                _in_fft_g.realp[j * _width + i] = G(color);
                _in_fft_g.imagp[j * _width + i] = 0;
                
                _in_fft_b.realp[j * _width + i] = B(color);
                _in_fft_b.imagp[j * _width + i] = 0;
                
                currentPixel++;
            }
        }
}
-( void) fftImage{
    
    UInt32 log2nc = log2(_width);
    UInt32 log2nr = log2(_height);

    NSInteger numElements = _width * _height;
    _rowStride = 1;
    _columnStride = 0;
    FFTSetupD setup = vDSP_create_fftsetupD(MAX(log2nr, log2nc), FFT_RADIX2);
    
    _out_fft_r.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _out_fft_r.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    
    vDSP_fft2d_zopD( setup, &_in_fft_r, _rowStride, _columnStride, &_out_fft_r, _rowStride, _columnStride, log2nc, log2nr, FFT_FORWARD );
    NSLog(@"After fft");
    
       
    _out_fft_g.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _out_fft_g.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    
    
    vDSP_fft2d_zopD( setup, &_in_fft_g, _rowStride, _columnStride, &_out_fft_g, _rowStride, _columnStride, log2nc, log2nr, FFT_FORWARD );
    NSLog(@"After fft");
    
    
    _out_fft_b.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    _out_fft_b.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    
    
    vDSP_fft2d_zopD( setup, &_in_fft_b, _rowStride, _columnStride, &_out_fft_b, _rowStride, _columnStride, log2nc, log2nr, FFT_FORWARD );
    NSLog(@"After fft");
    
     free(setup);

    
}

- (UIImage *)generateImageWidthPixielType:(PixielType )pixielType direction:(FFTType)direction{
      DOUBLE_COMPLEX_SPLIT channel;
      NSInteger N = _width * _height;
     UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * _height * _width);
    if(direction == FFTForwardType){
        switch (pixielType) {
            case PixielR:
                channel = _in_fft_r;
                break;
            case PixielG:
                channel = _in_fft_g;
                break;
            case PixielB:
                channel = _in_fft_b;
                break;
        }
         UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * _height * _width);
        for (NSInteger i = 0; i < N; i++) {
            UInt8 color = channel.realp[i];
            imageBuffer[i] = RGBAMake((int)color,(int)color,(int)color,255);
        }
    }else{
        switch (pixielType) {
            case PixielR:
                channel = _out_fft_r;
                break;
            case PixielG:
                 channel = _out_fft_g;
                break;
            case PixielB:
                 channel = _out_fft_b;
                break;
        }
        double logOfMaxMag = [self maxRadius:channel];
        for (NSInteger i = 0; i < N; i++) {
            double color = [self colorWith:logOfMaxMag realp:channel.realp[i] imagp:channel.imagp[i]];
            imageBuffer[i] = RGBAMake((int)color,(int)color,(int)color,255);
        }
    }
     return [UIImage imageFromRGB:imageBuffer width:_width height:_height];
}

- (UIImage *)generateImageWidthMatrix:(DOUBLE_COMPLEX_SPLIT )matrix width:(NSInteger)width height:(NSInteger)height{
     NSInteger N = width * height;
    UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * width * height);
    for (NSInteger i = 0; i < N; i++) {
        UInt8 color = matrix.realp[i];
        imageBuffer[i] = RGBAMake((int)color,(int)color,(int)color,255);
    }
     return [UIImage imageFromRGB:imageBuffer width:width height:height];
}



- (UIImage *)generateFFTImage{
     NSInteger N = _width * _height;
    UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * _height * _width);
    double logOfMaxMagR = [self maxRadius:_out_fft_r];
    double logOfMaxMagG = [self maxRadius:_out_fft_g];
    double logOfMaxMagB = [self maxRadius:_out_fft_b];
   
    for (NSInteger i = 0; i < N; i++) {
        double colorR =  [self colorWith:logOfMaxMagR realp:_out_fft_r.realp[i] imagp:_out_fft_r.imagp[i]];
        double colorG = [self colorWith:logOfMaxMagG realp:_out_fft_g.realp[i] imagp:_out_fft_g.imagp[i]];
        double colorB = [self colorWith:logOfMaxMagB realp:_out_fft_b.realp[i] imagp:_out_fft_b.imagp[i]];
        imageBuffer[i] = RGBAMake((int)colorR,(int)colorG,(int)colorB,255);
    }
    return [UIImage imageFromRGB:imageBuffer width:_width height:_height];
}

- (double )colorWith:(double)logOfMaxMag realp:(double)realp  imagp:(double)imagp{
    double radius = sqrt(realp * realp + imagp * imagp);
    double  color = log(9e-3 * radius + 1.0);
    return  255.0 * (color / logOfMaxMag);
}
- (double)maxRadius:(DOUBLE_COMPLEX_SPLIT )channel{
     NSInteger N = _width * _height;
    double maxRadius = 0;
    for (NSInteger i = 0; i < N; i++) {
        double radius = sqrt(channel.realp[i] * channel.realp[i] + channel.imagp[i] * channel.imagp[i]);
        if(radius > maxRadius){
            maxRadius = radius;
        }
    }
    return log(9e-3 * maxRadius + 1.0);
}


-(UIImage *)ifft{
    
    UInt32 log2nc = log2(_width);
    UInt32 log2nr = log2(_height);
    
    NSInteger numElements = _width * _height;
    
    double SCALE = 1.0/numElements;
    DOUBLE_COMPLEX_SPLIT out_ifft_r;
    out_ifft_r.realp = ( double * ) malloc ( numElements * sizeof ( double ) );
    out_ifft_r.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    
    FFTSetupD setup = vDSP_create_fftsetupD(MAX(log2nr, log2nc), FFT_RADIX2);
    
    
    vDSP_fft2d_zopD(setup, &_out_fft_r, _rowStride, _columnStride, &out_ifft_r, _rowStride, _columnStride, log2nc, log2nr, FFT_INVERSE);
    NSLog(@"after ifft");
    
    
    vDSP_vsmulD( out_ifft_r.realp, 1, &SCALE, out_ifft_r.realp, 1, numElements );
    vDSP_vsmulD( out_ifft_r.imagp, 1, &SCALE, out_ifft_r.imagp, 1, numElements );
    
    
    DOUBLE_COMPLEX_SPLIT out_ifft_g;
    out_ifft_g.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    out_ifft_g.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    

    vDSP_fft2d_zopD(setup, &_out_fft_g, _rowStride, _columnStride, &out_ifft_g, _rowStride, _columnStride, log2nc, log2nr, FFT_INVERSE);
    NSLog(@"after ifft");
    
 
    vDSP_vsmulD( out_ifft_g.realp, 1, &SCALE, out_ifft_g.realp, 1, numElements );
    vDSP_vsmulD( out_ifft_g.imagp, 1, &SCALE, out_ifft_g.imagp, 1, numElements );
    
    
    DOUBLE_COMPLEX_SPLIT out_ifft_b;
    out_ifft_b.realp = ( double* ) malloc ( numElements * sizeof ( double ) );
    out_ifft_b.imagp = ( double* ) malloc ( numElements * sizeof ( double ) );
    
    
    vDSP_fft2d_zopD(setup, &_out_fft_b, _rowStride, _columnStride, &out_ifft_b, _rowStride, _columnStride, log2nc, log2nr, FFT_INVERSE);
    NSLog(@"after ifft");
    
    vDSP_vsmulD( out_ifft_b.realp, 1, &SCALE, out_ifft_b.realp, 1, numElements );
    vDSP_vsmulD( out_ifft_b.imagp, 1, &SCALE, out_ifft_b.imagp, 1, numElements );
    
    UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * _height * _width);
    
    for(UInt32 i = 0;i < _width * _height; ++i)
    {
      imageBuffer[i] = RGBAMake((int)out_ifft_r.realp[i],(int)out_ifft_g.realp[i],(int)out_ifft_b.realp[i],255);
    }

    [self freeMemory:out_ifft_r];
    [self freeMemory:out_ifft_g];
    [self freeMemory:out_ifft_b];
    free(setup);
    UIImage *wm_image =  [UIImage imageFromRGB:imageBuffer width:_width height:_height];
    
    return [wm_image resizeImageWidth:_original_width height:_original_height ];;
}




- (void)addWatterMask:(UIImage* )mark{
    DOUBLE_COMPLEX_SPLIT channel = [self randomMatrixWidthImage:mark seed:_seed width:_width height:_height];
    [self addDigitalWatterMask:channel];

}
- (void)addDigitalWatterMask:(DOUBLE_COMPLEX_SPLIT )channel{
    
    for (NSInteger j = 0; j < _height; j++) {
        for (NSInteger i = 0; i < _width; i++) {
            NSInteger index = j * _width + i;
            
            _out_fft_r.realp[index] += channel.realp[index] * _alpha;
            _out_fft_g.realp[index] += channel.realp[index] * _alpha;
            _out_fft_b.realp[index] += channel.realp[index] * _alpha;
            
            _out_fft_r.imagp[index] += channel.realp[index] * _alpha;
            _out_fft_g.imagp[index] += channel.realp[index] * _alpha;
            _out_fft_b.imagp[index] += channel.realp[index] * _alpha;
        }
    }
    free(channel.realp);
}


+ (int)mySqrt:(double)real1 imagp1:(double)imagp1  real2:(double)real2 imagp2:(double)imagp2  alpha:(double)alpha{
    return sqrt(pow((real1 - real2)/alpha, 2) + pow((imagp1 - imagp2)/alpha, 2));
}
+ (UIImage *)restoreImageWidthProcess:(LHWatermarkProcessor *)origin watermask:(LHWatermarkProcessor *)watermask seed:(unsigned)seed{
    
    NSInteger w  =  watermask.width;
    NSInteger h =   watermask.height;
    
    UInt32 *imageBuffer =(UInt32 *) malloc(sizeof(UInt32) * h * w);
    
    double *delta =(double *) malloc(sizeof(double) * h * w);
    for (NSInteger j = 0; j < h; j++) {
        for (NSInteger i = 0; i < w; i++) {
            NSInteger index = j * w + i;
            
           int r =  [LHWatermarkProcessor mySqrt:watermask.out_fft_r.realp[index] imagp1:watermask.out_fft_r.imagp[index] real2:origin.out_fft_r.realp[index] imagp2:origin.out_fft_r.imagp[index] alpha:origin.alpha];
           int g =  [LHWatermarkProcessor mySqrt:watermask.out_fft_g.realp[index] imagp1:watermask.out_fft_g.imagp[index] real2:origin.out_fft_g.realp[index] imagp2:origin.out_fft_g.imagp[index] alpha:origin.alpha];
           int b =  [LHWatermarkProcessor mySqrt:watermask.out_fft_b.realp[index] imagp1:watermask.out_fft_b.imagp[index] real2:origin.out_fft_b.realp[index] imagp2:origin.out_fft_b.imagp[index] alpha:origin.alpha];
            
            int rgb = (r + g + b)/3.0;
            delta[index] = rgb;
            
        }
    }
    double max = 0;
    NSInteger i = 0;
    for ( i = 0 ; i < h * w; i++) {
        double rgb = delta[i];
        if(rgb > max){
            max = rgb;
        }
    }
    max = log(9e-3 * max + 1.0);
    for ( i = 0; i < h * w; i++) {
        double rgb = delta[i];
        rgb = log(9e-3 * rgb + 1.0);
        double color = (rgb/max) * 255.0;
        imageBuffer[i] = RGBAMake((int)color,(int)color,(int)color,255);
    }
    free(delta);
    return [UIImage restoreImageWidth:seed width:w height:h buff:imageBuffer];
    
}



- (DOUBLE_COMPLEX_SPLIT )randomMatrixWidthImage:(UIImage *)image  seed:(unsigned)seed width:(NSInteger)width height:(NSInteger)height{
    NSInteger N = width * height;
    NSAssert(width >= image.size.width, @"wattermask's width can not be bigger than origins'");
    NSAssert(height/2 >= image.size.height, @"wattermask's height can not be bigger than  half length of origin's ");
    //    double *matrix  = (double*) malloc(sizeof(double) * N);
    
    DOUBLE_COMPLEX_SPLIT matrix;
    matrix.realp = (double *) malloc(N*sizeof ( double ));
    for (NSInteger i = 0;i < N;i++) {
        matrix.realp[i] = 0;
        //        matrix.imagp[i] = 0;
    }
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
    
    
    UInt32 * imagePixels = [image UInt32ImageBuff];
    
    UInt32 * currentPixel = imagePixels;
    for (int j = 0; j < image.size.height; j++) {
        for (int i = 0; i < image.size.width; i++) {
            UInt32 color = *currentPixel;
            // random
            int rgb = (R(color) + G(color) + B(color))/3.0;
            rgb = 255 - rgb;
            //上半部分
            matrix.realp[random[j * width + i]] =  rgb;
            //            matrix.imagp[random[j * width + i]] =  rgb;
            //对称的下半部分
            matrix.realp[ N -random[j * width + i] - 1] =  rgb;
            //            matrix.imagp[ N -random[j * width + i] - 1] =  rgb;
            currentPixel++;
        }
    }
    free(order);
    free(random);
    free(imagePixels);
    return matrix;
}

- (void)freeMemory:(DOUBLE_COMPLEX_SPLIT) channel{
    if(channel.realp){
        free(channel.realp);
        free(channel.imagp);
    }
}
- (void)dealloc{
    
    [self freeMemory:_out_fft_r];
    [self freeMemory:_out_fft_g];
    [self freeMemory:_out_fft_b];
    
    [self freeMemory:_in_fft_r];
    [self freeMemory:_in_fft_g];
    [self freeMemory:_in_fft_b];
}


@end
