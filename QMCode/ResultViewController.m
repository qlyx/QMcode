
//
//  ResultViewController.m
//  QMCode
//
//  Created by 主用户 on 16/2/26.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 50)];
    lab.text = [NSString stringWithFormat:@"扫描结果是%@",self.str];
    lab.numberOfLines = 0;
    [self.view addSubview:lab];
    
   
    // Do any additional setup after loading the view.
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
