# LHWatermark


[![CocoaPods](https://img.shields.io/cocoapods/v/LHWatermark.svg)](http://cocoadocs.org/docsets/LHWatermark)
[![CocoaPods](https://img.shields.io/cocoapods/l/LHWatermark.svg)](https://raw.githubusercontent.com/iTofu/LHWatermark/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/p/LHWatermark.svg)](https://opensource.org/licenses/MIT)



LHWatermark可以给你的图片添加上盲水印。具体原理访问[博客](http://leonhwa.com/blog/0015035729130008548fcb1848747cab17f90a9fa92593e000)

## 演示
![shot01](https://github.com/LeonHwa/screenShot/blob/master/LHWatermark/shot02.png)
![shot02](https://github.com/LeonHwa/screenShot/blob/master/LHWatermark/shot01.png)

## 使用
#### 第一步
支持cocoaPods  在文件 Podfile 中加入以下内容：

` pod 'LHWatermark', '~> 0.0.3'` 

然后在终端中运行以下命令：
 
`pod install` 

#### 第二步
嵌入水印：

```
  //初始化
    LHWatermarkProcessor *  processor = [[LHWatermarkProcessor alloc] initWithImage:image config:[LHConfig defaultConfig]];
    __weak typeof(self) weakSelf = self;
    //把文字水印@"你的名字"添加到image中。 异步线程
    [processor addMarkText:@"你的名字"  result:^(UIImage *watermarkImage) {
        // block中返回加了水印的图片 主线程
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.topImgView.image = watermarkImage;
    }];
```

提取水印：
```
   UIImage *image = [UIImage imageNamed:ImageName];
     __weak typeof(self) weakSelf = self;
    // 分别传入原图像、加了水印的图像 。异步线程
    [LHWatermarkProcessor restoreImageWithOriginImage:image watermarkImage:[UIImage imageWithContentsOfFile:_imagePath] config:[LHConfig defaultConfig] result:^(UIImage *markImage) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
        // block中返回水印的图片 主线程
         strongSelf.bottomImgView.image = watermarkImage;
    }];
```


## License
本项目采用 [MIT license](https://opensource.org/licenses/MIT) 开源，你可以利用采用该协议的代码做任何事情，只需要继续继承 MIT 协议即可。
