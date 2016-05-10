//
//  WJServerVC.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/10.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJServerVC.h"
#import "OBDBluetooth.h"

@interface WJServerVC ()<OBDBluetoothDelegate>

@end

@implementation WJServerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务特征";
    [OBDBluetooth shareOBDBluetooth].delegate = self;
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)nextVC {
//刷新界面
    
    
    LOG(@"刷新界面");
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
