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

@interface WJPeripheralVC ()<OBDBluetoothDelegate>
@property (nonatomic, strong) NSMutableArray *rissArray;

@end

@implementation WJPeripheralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    [OBDBluetooth shareOBDBluetooth].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 属相 懒加载
//- (UITableView *)peripheresTableVC {
//    
//    if (!_peripheresTableVC) {
//        _peripheresTableVC = [[UITableView alloc]init];
//        _peripheresTableVC.dataSource = self;
//        _peripheresTableVC.delegate = self;
//        _peripheresTableVC.separatorStyle = UITableViewCellAccessoryNone;
//        [self.view addSubview:_peripheresTableVC];
//        _peripheresTableVC.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        
//    }
//    
//    return _peripheresTableVC;
//}

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
    cell.identifierLabel.text = peripheral.identifier.UUIDString;
    cell.rissLabel.text = [NSString stringWithFormat:@"%@",[self.rissArray objectAtIndex:indexPath.row]];
    
    
    return cell;
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.tableDataArray objectAtIndex:indexPath.row];
    [[OBDBluetooth shareOBDBluetooth]connectPeripheral:peripheral];
    
}

#pragma mark - 蓝牙代理方法

- (void) reloadTableView:(NSMutableArray *) peripheralA andRissArray:(NSMutableArray *)rissArray {
    self.tableDataArray = peripheralA;
    self.rissArray = rissArray;
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.baseTableVC reloadData];
    });
    
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
