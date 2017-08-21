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
#define ImageName @"yourName"
#define Alpha 3
#define Seed 1024
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *upImgView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImgView;
@property (nonatomic, copy) NSString *imagePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.upImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presenting:)]];
    [self.bottomImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presenting:)]];
    
    
    UIImage *image = [UIImage imageNamed:ImageName];
    LHWatermarkProcessor *  _process = [[LHWatermarkProcessor alloc] initWidthImage:image];
  self.upImgView.image =   [_process generateImageWidthPixielType:PixielR direction:FFTBackwardType];
    _process.alpha= Alpha;
    _process.seed = Seed;
    [_process addWatterMask:[UIImage imageWidthText:@"你的名字"]];
    UIImage *wm_image  = [_process ifft];
    
    self.upImgView.image = wm_image;
     NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     _imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"code_%@.png",ImageName]];
     [UIImagePNGRepresentation(wm_image) writeToFile:_imagePath  atomically:YES];
            NSLog(@"%@",_imagePath);

}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)restore:(id)sender {
     UIImage *image = [UIImage imageNamed:ImageName];
    LHWatermarkProcessor *  watermaskProcess = [[LHWatermarkProcessor alloc] initWidthImage:[UIImage imageWithContentsOfFile:_imagePath]];
    watermaskProcess.alpha= Alpha;

    
    LHWatermarkProcessor *  originalProcess = [[LHWatermarkProcessor alloc] initWidthImage:image];
    originalProcess.alpha= Alpha;

    
    UIImage *restoreMask  = [LHWatermarkProcessor restoreImageWidthProcess:originalProcess watermask:watermaskProcess seed:Seed];
    self.bottomImgView.image = [restoreMask resizeImageWidth:image.size.width height:image.size.height];
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


@end
