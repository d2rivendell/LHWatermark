//
//  NextViewController.m
//  LHWatermarkExample
//
//  Created by Leon on 2017/6/29.
//  Copyright © 2017年 LeonHwa. All rights reserved.
//

#import "NextViewController.h"

@interface NextViewController ()

@property (strong, nonatomic) UIImageView *imgView;
@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imgView];
    self.imgView.userInteractionEnabled = YES;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.image = self.image;
    self.imgView.backgroundColor = self.imgColor;
    [self.imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressAction)];
    press.minimumPressDuration = 0.8;
    [self.imgView addGestureRecognizer:press];
    
}
- (void)pressAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"要保存到本地吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle: @"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle: @"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
         UIImageWriteToSavedPhotosAlbum(strongSelf.imgView.image, strongSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
        if (error) {
            NSLog(@"保存失败");
        }else{
            NSLog(@"保存成功");
        }
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
