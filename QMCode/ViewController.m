//
//  ViewController.m
//  QMCode
//
//  Created by 主用户 on 16/2/26.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import "ViewController.h"
#import "QMYViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
{
    UITextField *tf_text;
    UIImageView *img;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initview];
}
-(void)initview
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 60, 150, 50)];
    [btn setTitleColor:[UIColor blackColor] forState:0];
    [btn setTitle:@"扫描二维码" forState:0];
    [btn addTarget:self action:@selector(scanCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    tf_text = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 150, 50)];
    tf_text.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tf_text];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(170, 120, 150, 50)];
    [btn1 setTitleColor:[UIColor blackColor] forState:0];
    [btn1 setTitle:@"生成二维码" forState:0];
    [btn1 addTarget:self action:@selector(CreatCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 200, 200, 200)];
    img.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:img];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scanCode:(id)sender {
   
        // iOS 8 后，全部都要授权
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined:{
                // 许可对话没有出现，发起授权许可
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    
                    if (granted) {
                        //第一次用户接受
                        QMYViewController *qm = [[QMYViewController alloc] init];
                        [self.navigationController pushViewController:qm animated:YES];
                    }else{
                        //用户拒绝
                        NSLog(@"用户明确地拒绝授权,请打开权限");
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized:{
                // 已经开启授权，可继续
                QMYViewController *qm = [[QMYViewController alloc] init];
                [self.navigationController pushViewController:qm animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                // 用户明确地拒绝授权，或者相机设备无法访问
                NSLog(@"用户明确地拒绝授权，或者相机设备无法访问,请打开权限");
                break;
            default:
                break;
        }
        
    

}

- (void)CreatCode:(id)sender {
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[tf_text.text dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    img.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:100.0];
    
    
    
//    //如果还想加上阴影，就在ImageView的Layer上使用下面代码添加阴影
//    
//    _imgView.layer.shadowOffset=CGSizeMake(0, 0.5);//设置阴影的偏移量
//    
//    _imgView.layer.shadowRadius=1;//设置阴影的半径
//    
//    _imgView.layer.shadowColor=[UIColor blackColor].CGColor;//设置阴影的颜色为黑色
//    
//    _imgView.layer.shadowOpacity=0.3;
}
//改变二维码大小

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}


@end
