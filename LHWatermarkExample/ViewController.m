//
//  ViewController.m
//  LHWatermarkExample
//
//  Created by Leon on 2017/6/29.
//  Copyright © 2017年 LeonHwa. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Helper.h"
#import "LHWatermarkProcessor.h"
#import "NextViewController.h"
#import "LHConfig.h"
#define ImageName @"yourName"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *topImgView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImgView;
@property (nonatomic, copy) NSString *imagePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.topImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presenting:)]];
    [self.bottomImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presenting:)]];
    UIImage *image = [UIImage imageNamed:ImageName];
    
    
    LHWatermarkProcessor *  processor = [[LHWatermarkProcessor alloc] initWidthImage:image config:[LHConfig defaultConfig]];
    
    __weak typeof(self) weakSelf = self;
    [processor addMarkText:@"你的名字"  result:^(UIImage *watermarkImage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.topImgView.image = watermarkImage;
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"code_%@.png",ImageName]];
        [UIImagePNGRepresentation(watermarkImage) writeToFile:_imagePath  atomically:YES];
        NSLog(@"%@",_imagePath);
    }];


}


- (IBAction)restore:(id)sender {
     UIImage *image = [UIImage imageNamed:ImageName];
     __weak typeof(self) weakSelf = self;
    // 传入元图像和加了水印的图像 异步线程
    [LHWatermarkProcessor restoreImageWidthOriginImage:image watermarkImage:[UIImage imageWithContentsOfFile:_imagePath] config:[LHConfig defaultConfig] result:^(UIImage *markImage) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
        // block中返回水印的图片 主线程
         strongSelf.bottomImgView.image = markImage;
    }];
   
}

- (void)presenting:(UITapGestureRecognizer *)tap{
    UIImageView *imgView = (UIImageView *)tap.view;
    NextViewController *nVC = [[NextViewController alloc] init];
    nVC.image = imgView.image;
    nVC.imgColor = imgView.backgroundColor;
    [self presentViewController:nVC animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
