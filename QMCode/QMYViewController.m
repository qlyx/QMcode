//
//  ResultViewController.h
//  QMCode
//
//  Created by 主用户 on 16/2/26.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import "QMYViewController.h"
#import "ResultViewController.h"
#import <AVFoundation/AVFoundation.h>
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#define Qmyalpha 0.4

@interface QMYViewController ()<AVCaptureMetadataOutputObjectsDelegate>//用于处理采集信息的代理
{
    AVCaptureSession * session;//输入输出的中间桥梁
    AVCaptureMetadataOutput * output;
    UIImageView * _QimageView ;
    UIImageView *_QrCodeline ;
    NSTimer *_timer;
    UIImage *_linimg;
    UILabel *lab;
    int index;
    //
}
@end

@implementation QMYViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    self.edgesForExtendedLayout = UIRectEdgeNone;
        
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    index = 0;
    [session startRunning];
    [self createTimer];
    
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationItem.title = @"扫描二维码";
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        //获取摄像设备
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        //创建输出流
        output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        session = [[AVCaptureSession alloc]init];
        //高质量采集率
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [session addInput:input];
        [session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        layer.frame=self.view.layer.bounds;
        [self.view.layer insertSublayer:layer atIndex:0];
        //可根据此方法传入相应的扫描框和扫描线图片
        [self initWithScanViewName:@"capture" withScanLinaName:@"scan_line" withPickureZoom:0.6];
    }else
    {
        NSLog(@"该设备无法使用相机功能");
    }
    
}

-(void)initWithScanViewName:(NSString *)ScvName withScanLinaName:(NSString *)SclName withPickureZoom:(CGFloat)pkz
{
    
    
    
    [self setScanImageView:ScvName withZoom:pkz];
    [self setScanLine:SclName withZoom:pkz];
    [self setScanBackView];

   
}
#pragma mark-method

//设置扫描这该区域
-(void) setScanBackView
{
    CGFloat MaxY = CGRectGetMaxY(_QimageView.frame);
    [output setRectOfInterest:CGRectMake(_QimageView.frame.origin.y/self.view.frame.size.height, _QimageView.frame.origin.x/self.view.frame.size.width, _QimageView.frame.size.height/ScreenH, _QimageView.frame.size.width/ScreenW)];

    //上方遮盖层
    UIView * upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width,_QimageView.frame.origin.y )];
    upView.backgroundColor = [UIColor blackColor];
    upView.alpha = Qmyalpha;
    [self.view addSubview:upView];
    //左侧遮盖层
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, _QimageView.frame.origin.y, _QimageView.frame.origin.x, _QimageView.frame.size.height)];
    leftView.backgroundColor = [UIColor blackColor];
    leftView.alpha = Qmyalpha;
    [self.view addSubview:leftView];
    //右侧遮盖层
    UIView * rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) + _QimageView.frame.size.width, leftView.frame.origin.y, leftView.frame.size.width, leftView.frame.size.height)];
    rightView.backgroundColor = [UIColor blackColor];
    rightView.alpha = Qmyalpha;
    [self.view addSubview:rightView];
    //下方遮盖曾
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, MaxY, self.view.frame.size.width, ScreenH-MaxY)];
    downView.backgroundColor = [UIColor blackColor];
    downView.alpha = Qmyalpha;
    [self.view addSubview:downView];
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(0, downView.frame.origin.y+30, self.view.frame.size.width, 30)];
    lab.text = @"将二维码图片对准扫描框即可自动扫描";
    lab.textColor = [UIColor whiteColor];
  
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];
}
//小数转换
-(CGFloat) conversionFloat:(CGFloat) ofloat
{
    NSString * str =[NSString stringWithFormat:@"%.1f",ofloat ];
    CGFloat a  = str.floatValue;
//    int a = (int)(ofloat+0.5);
//    CGFloat b =(CGFloat) a;
    return a;
}
//根据传入图片设置扫描框
-(void) setScanImageView:(NSString *) imageName withZoom:(CGFloat) imageZoom
{
    CGFloat new = [self conversionFloat:imageZoom];
    UIImage * img = [UIImage imageNamed:imageName];
    CGFloat x = (self.view.frame.size.width- img.size.width*new)/2;
    
    CGFloat y = self.view.frame.size.height/2-img.size.height*new-20;
   
    UIImageView * imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(x, y, img.size.width*new, img.size.height*new);
    _QimageView = imgView;
    [self.view addSubview:imgView];
}
//根据传入图片设置扫码线
-(void) setScanLine:(NSString *) lineImageName withZoom:(CGFloat) imageZoom
{
    _linimg = [UIImage imageNamed:lineImageName];
    _QrCodeline = [[ UIImageView alloc ] initWithImage:_linimg];
    _QrCodeline.frame = CGRectMake(_QimageView.frame.origin.x , _QimageView.frame.origin.y, _QimageView.frame.size.width, _linimg.size.height*imageZoom);
    
    [ self.view addSubview : _QrCodeline ];
}
- ( void )moveUpAndDownLine

{
    CGFloat QY = _QimageView.frame.origin.y;
    CGFloat QMY = CGRectGetMaxY(_QimageView.frame);
    CGFloat Y= _QrCodeline . frame . origin . y ;
    if (Y == QY ){
        
        [UIView beginAnimations: @"asa" context: nil ];
        
        [UIView setAnimationDuration: 1 ];
        _QrCodeline.transform = CGAffineTransformMakeTranslation(0,_QimageView.frame.size.height-4);
        [UIView commitAnimations];

    } else if (Y == QMY-4){
        
        [UIView beginAnimations: @"asa" context: nil ];
        
        [UIView setAnimationDuration: 1 ];
        _QrCodeline.transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView commitAnimations];
    }
    
}

- ( void )createTimer

{
    
    //创建一个时间计数
    
    _timer=[NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector (moveUpAndDownLine) userInfo: nil repeats: YES ];
    
}

- ( void )stopTimer

{
    
    if ([_timer isValid] == YES ) {
        
        [_timer invalidate];
        
        _timer = nil ;
        
    }
    
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
        
    {
        
        //停止扫描
        
        [session stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
        stringValue = metadataObject.stringValue;
        NSLog(@"%@",stringValue);
        //处理扫描数据 此处index只是为了避免系统api多次调用此代理方法，多次处理扫描数据，置为1就表明已经获取到扫描结果并处理，无需再次处理，因为之前遇到过扫描的时候一直不停的打印扫描结果
        if (index == 0) {
            //判断一下当前扫描得到的字符串字符个数是否大于“http://”的长度，避免截取字符串时越界
            if (stringValue.length>7) {
                NSLog(@"%@",[stringValue substringToIndex:12]);
                //@"http://"长度为7 @"itms-apps://"长度为12  网址必须是这两个开头才可以跳转
                if ([[stringValue substringToIndex:7] isEqualToString:@"http://"]||[[stringValue substringToIndex:12] isEqualToString:@"itms-apps://"]) {
                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
                }else
                {
                    //不是网址直接显示
                    ResultViewController *qm = [[ResultViewController alloc] init];
                    qm.str = stringValue;
                    [self.navigationController pushViewController:qm animated:YES];

                }
                
            }else{
                //长度不够直接显示当前扫描到的字符串
                ResultViewController *qm = [[ResultViewController alloc] init];
                qm.str = stringValue;
                [self.navigationController pushViewController:qm animated:YES];

                }
            index = 1;
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [session startRunning];
    [self stopTimer];
}

@end
