//
//  WJPeripheralVC.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/9.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJPeripheralVC.h"
#import "WJPeripheralCell.h"
#import "OBDBluetooth.h"
#import "WJServerVC.h"

@interface WJPeripheralVC ()<OBDBluetoothDelegate>
@property (nonatomic, strong) NSMutableArray *rissArray;
@property (nonatomic, strong) UILabel *noPeripheralView;

@end

@implementation WJPeripheralVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //每次显示界面  重新设置代理  扫描设别
    [OBDBluetooth shareOBDBluetooth].delegate = self;
    [[OBDBluetooth shareOBDBluetooth] scanPeripheral];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    
    //在没有搜索到设备的时候  提示用户没有搜索到设备
    _noPeripheralView  = [[UILabel alloc]initWithFrame:self.view.frame];
    _noPeripheralView.text = @"亲\n\n搜索不到设备！\n\n请打开您要连接的设备";
    _noPeripheralView.font = WJFont(25);
    _noPeripheralView.textAlignment = NSTextAlignmentCenter;
    _noPeripheralView.numberOfLines = 0;
    [self.view addSubview:_noPeripheralView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 属相 懒加载

- (NSMutableArray *)rissArray {
    if (!_rissArray) {
        _rissArray = [NSMutableArray array];
    }
    return _rissArray;
}

#pragma mark - tableview 代理方法


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"peripheralCell";
    WJPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJPeripheralCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CBPeripheral *peripheral = [self.tableDataArray objectAtIndex:indexPath.row];
    //LOG(@"%@",peripheral);
    
    cell.titleLabel.text = peripheral.name;
    //peripheral.identifier.UUIDString
    //    NSString *idenfirierS = [NSString stringWithFormat:@"%d服务",[peripheral.services count]];
    cell.identifierLabel.text =  peripheral.identifier.UUIDString;
    cell.rissLabel.text = [NSString stringWithFormat:@"%@",[self.rissArray objectAtIndex:indexPath.row]];
    
    
    return cell;
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.tableDataArray objectAtIndex:indexPath.row];
    
    [[OBDBluetooth shareOBDBluetooth]connectPeripheral:peripheral];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark - 蓝牙代理方法

- (void) reloadTableView:(NSMutableArray *) peripheralA andRissArray:(NSMutableArray *)rissArray {
    self.tableDataArray = peripheralA;
    self.rissArray = rissArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.tableDataArray count] > 0) {
            _noPeripheralView.hidden = YES;
        }else {
            _noPeripheralView.hidden = NO;
        }
        
         [self.baseTableVC reloadData];
    });
    
}


-(void)nextVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        LOG(@"界面跳转");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.navigationController pushViewController:[[WJServerVC alloc]init] animated:YES];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        });
        
        
    });
}

- (void)didDisconnectPeripheral {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}


- (void)readDataForString {
    LOG(@"读取到数据的 代理方法");
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
