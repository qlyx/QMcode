//
//  ResultViewController.h
//  QMCode
//
//  Created by 主用户 on 16/2/26.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanDelegete <NSObject>

-(void)equmname:(NSString *)name;

@end
@interface QMYViewController : UIViewController
@property (nonatomic,copy) NSString * scanImageViewName;
@property (nonatomic,copy) NSString * scanImgaeName;
@property (nonatomic) int  from;
@property (nonatomic,weak) id<ScanDelegete> delegate;
//调用自定义的初始化方法  传入扫描框，扫描线图片和图片缩放比例 
-(void) initWithScanViewName:(NSString *)ScvName withScanLinaName:(NSString*) SclName withPickureZoom:(CGFloat) pkz;
@end
