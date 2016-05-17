//
//  WJServerVC.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/10.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJServerVC.h"
#import "OBDBluetooth.h"
#import "WJServerCell.h"
#import "WJPeripheralCell.h"
#import "WJCharacteristicVC.h"

@interface WJServerVC ()<OBDBluetoothDelegate>
@property (nonatomic, strong) NSArray *sectonArray;


@end

@implementation WJServerVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [OBDBluetooth shareOBDBluetooth].delegate = self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务";
    
    self.sectonArray = [OBDBluetooth shareOBDBluetooth].peripheral.services;
    
    
    //创建头文件  tableview的头
    UIView * sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
//    sectionView.backgroundColor = [UIColor orangeColor];
    UILabel * label = [[UILabel alloc]init];
    label.frame = CGRectMake(10, 0, SCREEN_WIDTH - 15, 80);
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"设备名: %@\nUUID: %@",[OBDBluetooth shareOBDBluetooth].peripheral.name,[OBDBluetooth shareOBDBluetooth].peripheral.identifier.UUIDString];
    
    [sectionView addSubview:label];
    [self.baseTableVC setTableHeaderView:sectionView];
    [self setBarItem];
    
    // Do any additional setup after loading the view.
}

- (void)onClick:(id)sender {
    [[OBDBluetooth shareOBDBluetooth] disconnectPeripheral:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}


#pragma mark - 属性
- (NSArray *)sectonArray {
    if (!_sectonArray) {
        _sectonArray = [NSArray array];
    }
    return _sectonArray;
}


#pragma mark - tableview 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  [self.sectonArray count];
}

//每一个分区的头
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CBService *service = [self.sectonArray objectAtIndex:section];
    
    NSString *uuidData = [NSString stringWithFormat:@"%@",service.UUID.data];
    NSString *uuidS = [NSString stringWithFormat:@"%@",service.UUID];
    NSCharacterSet*set = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    uuidS = [uuidS  stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuidData = [uuidData stringByTrimmingCharactersInSet:set];
    uuidData = [uuidData stringByReplacingOccurrencesOfString:@" " withString:@""];
    uuidData = [uuidData uppercaseString];
    
    if (![uuidData isEqualToString:uuidS]) {
        return [NSString stringWithFormat:@"%@  %@",service.UUID,uuidData];
    }else {
        return [NSString stringWithFormat:@"UUID：%@",service.UUID];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 100;
    }else {
        return 60;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CBService *service = [self.sectonArray objectAtIndex:section];
    return [service.characteristics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"peripheralCell";
    WJServerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJServerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    CBService *service = [self.sectonArray objectAtIndex:indexPath.section];
    NSArray *characArray = service.characteristics;
    
    
    CBCharacteristic *characteristic = [characArray objectAtIndex:indexPath.row];
    
    
    //uuid
    NSString *uuidData = [NSString stringWithFormat:@"%@",characteristic.UUID.data];
    NSString *uuidS = [NSString stringWithFormat:@"%@",characteristic.UUID];
    //LOG(@"uuids = %@ \n uuidData = %@ ",uuidS,uuidData);

    /*
     1,
     uuids = 49535343-ACA3-481C-91EC-D85E28A60318
     uuidData = <49535343 aca3481c 91ecd85e 28a60318>
     
     2.
     uuids = Software Revision String
     uuidData = <2a28>
     
     3.
     uuids = FFF2
     uuidData = <fff2>
     */
    //字符串第二次处理
    
    
    
    
    
    //字符串的处理
    NSCharacterSet*set = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    uuidS = [uuidS  stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuidData = [uuidData stringByTrimmingCharactersInSet:set];
    uuidData = [uuidData stringByReplacingOccurrencesOfString:@" " withString:@""];
    uuidData = [uuidData uppercaseString];
    if (![uuidData isEqualToString:uuidS]) {
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ :%@",characteristic.UUID,uuidData];
    }else {
        cell.nameLabel.text = [NSString stringWithFormat:@"%@",characteristic.UUID];
    }

    NSString *proString =[self propertiesForString: characteristic.properties];
    
    //字符串第二次处理
    NSMutableArray * mutableArray = [[OBDBluetooth shareOBDBluetooth].readDataDic objectForKey:characteristic.UUID];
    LOG(@"uuisd = %@  array = %@  row = %d",characteristic.UUID, mutableArray, indexPath.row);
    if ([mutableArray count] >= 1 ) {
        NSData * data  = [mutableArray firstObject];
        if ([data bytes]) {
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            if (string) {
                cell.desLabel.text = [NSString stringWithFormat:@"属性：%@  %@",proString ,string];
            }else {
                cell.desLabel.text = [NSString stringWithFormat:@"属性：%@ %@",proString,[NSString stringWithFormat:@"%@",data]];
            }
        }else {
//            NSString *string = [NSString stringWithFormat:@"%@",data];
//            if (string) {
//                cell.desLabel.text = [NSString stringWithFormat:@"属性：%@  %@",proString ,string];
//            }else {
//                cell.desLabel.text = [NSString stringWithFormat:@"属性：%@",proString];
//            }
            cell.desLabel.text = [NSString stringWithFormat:@"属性：%@",proString];
        }
        
    }else {
        cell.desLabel.text = [NSString stringWithFormat:@"属性：%@",proString];
    }
    
    // //第一次处理字符串  和读到的字符串的格式是相对应的
//    NSString * valueString = [[OBDBluetooth shareOBDBluetooth].readDataDic objectForKey:characteristic.UUID];
//    if (valueString) {
//        cell.desLabel.text = [NSString stringWithFormat:@"属性：%@  %@",proString ,valueString];
//    }else {
//        cell.desLabel.text = [NSString stringWithFormat:@"属性：%@",proString];
//    }
    //cell.desLabel.text = [NSString stringWithFormat:@"属性：%@ ,%d  %@",proString ,characteristic.properties,valueString];
   
 
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    CBService *service = [self.sectonArray objectAtIndex:indexPath.section];
    NSArray *characArray = service.characteristics;
    WJCharacteristicVC * characVC = [[WJCharacteristicVC alloc]init];
    characVC.characteristic =[characArray objectAtIndex:indexPath.row];
    
    
    [self.navigationController pushViewController:characVC animated:YES];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)nextVC {
//刷新界面
    
    LOG(@"刷新界面");
    
    
}

- (void)didDisconnectPeripheral {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)readDataForString {
    LOG(@"服务界面 读取到数据的 代理方法");
}

/*
 enum {
 1 CBCharacteristicPropertyBroadcast = 0x01,//可广播  1
 2 CBCharacteristicPropertyRead = 0x02,//读  2
 4 CBCharacteristicPropertyWriteWithoutResponse = 0x04,//写无回复  4
 8 CBCharacteristicPropertyWrite = 0x08,//写
 16 CBCharacteristicPropertyNotify = 0x10,//订阅
 32 CBCharacteristicPropertyIndicate = 0x20,//声明
 64 CBCharacteristicPropertyAuthenticatedSignedWrites = 0x40,//通过验证的
 128 CBCharacteristicPropertyExtendedProperties = 0x80,//拓展
 
 
 // 标识这个characteristic的属性是需要加密的通知
 256 CBCharacteristicPropertyNotifyEncryptionRequiredNS_ENUM_AVAILABLE(NA, 6_0)= 0x100,
 // 标识这个characteristic的属性是需要加密的申明
 512 CBCharacteristicPropertyIndicateEncryptionRequiredNS_ENUM_AVAILABLE(NA, 6_0)= 0x200
 };
 */

#pragma mark - 属性处理
- (NSString *)propertiesForString:(int)proerities {
    
    NSString * proertiesString = nil;
 
    
    NSArray * stringArray = @[@"需要加密的申请",@"需要加密的通知",@"拓展",@"通过验证的",@"声明",@"订阅",@"可写",@"写无回复",@"可读",@"可广播"];
    NSArray *dataArray = @[@512,@256,@128,@64,@32,@16,@8,@4,@2,@1];
    for(int i = 0; i < [stringArray count]; i ++ ) {
        if (proerities >= [[dataArray objectAtIndex:i] integerValue]) {
            if (proertiesString) {
                proertiesString = [NSString stringWithFormat:@"%@|%@",[stringArray objectAtIndex:i],proertiesString];
            }else {
                proertiesString = [stringArray objectAtIndex:i];
            }
            
            proerities -= [[dataArray objectAtIndex:i] integerValue];
            if (proerities <= 0) {
                break;
            }
        }
    }

    
    return proertiesString;
}

//使用位与运算  http://lecason.com/2015/08/19/Objective-C-Find-Conbine/
-(void)logCharacteristicProperties:(CBCharacteristicProperties)properties
{
    if (properties & CBCharacteristicPropertyBroadcast) {
        NSLog(@"CBCharacteristicPropertyBroadcast");
    }
    if (properties & CBCharacteristicPropertyRead) {
        NSLog(@"CBCharacteristicPropertyRead");
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        NSLog(@"CBCharacteristicPropertyWriteWithoutResponse");
    }
    if (properties & CBCharacteristicPropertyWrite) {
        NSLog(@"CBCharacteristicPropertyWrite");
    }
    if (properties & CBCharacteristicPropertyNotify) {
        NSLog(@"CBCharacteristicPropertyNotify");
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        NSLog(@"CBCharacteristicPropertyIndicate");
    }
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        NSLog(@"CBCharacteristicPropertyAuthenticatedSignedWrites");
    }
    if (properties & CBCharacteristicPropertyExtendedProperties) {
        NSLog(@"CBCharacteristicPropertyExtendedProperties");
    }
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        NSLog(@"CBCharacteristicPropertyNotifyEncryptionRequired");
    }
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        NSLog(@"CBCharacteristicPropertyIndicateEncryptionRequired");
    }
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
